import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:work_o_clock/src/models/employee_model.dart';
import 'package:work_o_clock/src/screens/chat/chat_image_preview_screen.dart';
import 'package:work_o_clock/src/screens/chat/employee_detail_screen.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_chat_field.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final SocketService socketService = SocketService();
  final ScrollController _scrollController = ScrollController();

  late String roomId;
  bool isTyping = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    roomId = generateRoomId(widget.senderId, widget.receiverId);
    fetchOldMessages();
    initSocketConnections();
  }

  Future<void> initSocketConnections() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('token') ?? '';

    roomId = generateRoomId(widget.senderId, widget.receiverId);

    await socketService.initChatSocket(token, onConnect: () {
      socketService.joinRoom(roomId);
    });

    // Attach listeners
    socketService.onMessageReceived = (message) {
      if (mounted && message['sender_id'] != widget.senderId) {
        setState(() {
          messages.add({
            "text": message['content'],
            "isUserMessage": false,
            "media":
                message['media']?.isNotEmpty == true ? message['media'] : null,
            "timestamp": message['timestamp'],
          });
        });
        _scrollToBottom();
      }
    };

    socketService.onTyping = (_) => setState(() => isTyping = true);
    socketService.onStopTyping = (_) => setState(() => isTyping = false);
  }

  String formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString()).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

  void onTyping() {
    if (!isTyping) {
      socketService.typing(roomId);
    }
  }

  void onStopTyping() {
    if (isTyping) {
      socketService.stopTyping(roomId);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Generate room ID by sorting the user IDs
  String generateRoomId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('-');
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      final content = messageController.text;
      socketService.sendMessage(
        roomId,
        widget.senderId,
        widget.receiverId,
        content,
        '',
        widget.senderName,
        widget.receiverName,
      );
      if (mounted) {
        setState(() {
          messages.add({"text": content, "isUserMessage": true});
        });
      }
      _scrollToBottom();
      messageController.clear();
    }
  }

  Future<void> sendImage(String roomId, String senderId, String receiverId,
      String content, File mediaFile) async {
    String imageUrl = '';

    try {
      setState(() => isUploading = true);
      _scrollToBottom();
      // Upload the image to Supabase Storage
      final fileName =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('work-image')
          .upload(fileName, mediaFile);

      // Get the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('work-image')
          .getPublicUrl(fileName);
      imageUrl = publicUrl;
    } catch (error) {
      // Handle upload failure
      Get.snackbar('Error', 'An error occurred while uploading image: $error',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      socketService.sendMessage(
        roomId,
        senderId,
        receiverId,
        content,
        imageUrl,
        widget.senderName,
        widget.receiverName,
      );

      if (mounted) {
        setState(() {
          messages.add({
            "text": content,
            "isUserMessage": true,
            "media": imageUrl.isNotEmpty ? imageUrl : null,
          });
          isUploading = false;
        });
      }
    } catch (e) {
      setState(() => isUploading = false);
      Get.snackbar('Error', 'An error occurred while sending message: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> sendFile(String roomId, String senderId, String receiverId,
      String content, File mediaFile) async {
    String fileUrl = '';

    try {
      setState(() => isUploading = true);
      _scrollToBottom();
      // Upload the image to Supabase Storage
      final fileName =
          'chat_files/${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Supabase.instance.client.storage
          .from('work-image')
          .upload(fileName, mediaFile);

      // Get the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('work-image')
          .getPublicUrl(fileName);
      fileUrl = publicUrl;
    } catch (error) {
      // Handle upload failure
      Get.snackbar('Error', 'An error occurred while uploading image: $error',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      socketService.sendMessage(roomId, senderId, receiverId, content, fileUrl,
          widget.senderName, widget.receiverName);

      if (mounted) {
        setState(() {
          messages.add({
            "text": content,
            "isUserMessage": true,
            "media": fileUrl.isNotEmpty ? fileUrl : null,
          });
          isUploading = false;
        });
      }
    } catch (e) {
      setState(() => isUploading = false);
      Get.snackbar('Error', 'An error occurred while sending message: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchOldMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3003/api/messages/$roomId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 'data' is a list
        if (data['data'] is List) {
          List<Map<String, dynamic>> fetchedMessages =
              List<Map<String, dynamic>>.from(
            data['data'].map((message) => {
                  "text": message['content'],
                  "isUserMessage": message['sender_id'] == widget.senderId,
                  "media": message['media']?.isNotEmpty == true
                      ? message['media']
                      : null,
                  "timestamp": message['timestamp'],
                }),
          );

          setState(() {
            messages.insertAll(0, fetchedMessages);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching old messages: $e");
    }
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      await Get.to(ChatImagePreviewScreen(
        imageFile: imageFile,
        onSend: (String caption, File file) async {
          await sendImage(
              roomId, widget.senderId, widget.receiverId, caption, file);
        },
      ));

      return imageFile;
    }

    return null;
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      sendFile(roomId, widget.senderId, widget.receiverId, '', file);
      return file;
    }
    return null;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isTyping)
                  const Text(
                    'Typing...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                else
                  const Text(
                    'Last seen recently',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                final pref = await SharedPreferences.getInstance();
                final token = pref.getString('token') ?? '';

                try {
                  final response = await http.get(
                    Uri.parse(
                        'http://localhost:3000/api/users/get-user/${widget.receiverId}'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                  );

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    final user = data['user'];

                    final employee = Employee(
                      name: user['name'] ?? '',
                      email: user['email'] ?? '',
                      phone: user['phone'] ?? '',
                      department: user['department']?['name'] ?? '',
                      jobTitle: user['job']?['name'] ?? '',
                      dateOfBirth: user['dateofbirth'] ?? '',
                    );
                    Get.to(UserProfileScreen(employee: employee));
                  } else {
                    Get.snackbar("Error", "Failed to fetch user profile");
                  }
                } catch (e) {
                  Get.snackbar("Error",
                      "Something went wrong while fetching user profile");
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade300,
                child: Text(
                  _getInitials(widget.receiverName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start messaging right now',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUserMessage = message['isUserMessage'];
                      final time = formatTime(message['timestamp']);

                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: message['media'] != null
                            ? _buildMediaMessage(
                                message['media'], isUserMessage, time)
                            : _buildTextMessage(
                                message['text'], isUserMessage, time),
                      );
                    },
                  ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Typing...'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file,
                      color: BaseColors.primaryColor),
                  onPressed: () {
                    pickFile();
                  },
                ),
                IconButton(
                  onPressed: () {
                    pickImage();
                  },
                  icon: const Icon(Icons.camera_alt,
                      color: BaseColors.primaryColor),
                ),
                BaseChatField(messageController: messageController),
                IconButton(
                  icon: const Icon(Icons.send, color: BaseColors.primaryColor),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextMessage(String text, bool isUserMessage, String time) {
  return Column(
    crossAxisAlignment:
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isUserMessage ? BaseColors.primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
      )
    ],
  );
}

Widget _buildMediaMessage(String mediaUrl, bool isUserMessage, String time) {
  final fileName = Uri.parse(mediaUrl).pathSegments.last;
  final isImage = mediaUrl.toLowerCase().endsWith('.jpg') ||
      mediaUrl.toLowerCase().endsWith('.jpeg') ||
      mediaUrl.toLowerCase().endsWith('.png') ||
      mediaUrl.toLowerCase().endsWith('.webp') ||
      mediaUrl.toLowerCase().endsWith('.png');

  return Column(
    crossAxisAlignment:
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () async {
          try {
            final response = await http.get(Uri.parse(mediaUrl));
            if (response.statusCode == 200) {
              final directory = await getTemporaryDirectory();
              final filePath = '${directory.path}/$fileName';
              final file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);
              await OpenFile.open(filePath);
            }
          } catch (e) {
            Get.snackbar('Error', 'Failed to open file');
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUserMessage ? BaseColors.primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mediaUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const CircularProgressIndicator(),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insert_drive_file,
                        size: 40,
                        color: isUserMessage
                            ? Colors.white
                            : BaseColors.primaryColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        fileName,
                        style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(time,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    ],
  );
}
