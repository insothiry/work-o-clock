import 'package:flutter/material.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_chat_field.dart';
import 'package:work_o_clock/src/widgets/chat_action_listile.dart';
import 'package:work_o_clock/src/widgets/image_container_chat.dart';
import 'package:work_o_clock/src/widgets/message_container.dart';
import 'package:work_o_clock/src/widgets/priority_flags.dart';

class GroupChatScreen extends StatefulWidget {
  final String chatTitle;

  const GroupChatScreen({
    super.key,
    required this.chatTitle,
  });

  @override
  GroupChatScreenState createState() => GroupChatScreenState();
}

class GroupChatScreenState extends State<GroupChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    socketService.connect();
    socketService.onMessageReceived = (message) {
      setState(() {
        messages.add({"text": message, "isUserMessage": false});
      });
    };
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({"text": text, "isUserMessage": true});
      });
      socketService.sendMessage(text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BaseColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            widget.chatTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          /// DUMMY MESSAGE
          const ChatActionListTile(
              name: 'Thiry', action: 'has created this meeting'),
          const MessageContainer(
              isUserMessage: true, message: {'text': 'Good morning everyone!'}),
          const MessageContainer(
            isUserMessage: false,
            message: {'text': 'Good morning sir'},
            profileImage: 'assets/images/iu_pf.jpg',
          ),
          const ChatActionListTile(
            name: 'Thiry',
            action: 'has assign the task to',
            postAction: Text(
              'Jungkook',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const ChatActionListTile(
            name: 'Thiry',
            action: 'has set the task priority to',
            postAction: PriorityFlag(priority: 'low'),
          ),
          const MessageContainer(isUserMessage: true, message: {
            'text':
                'I have assigned new task to you, Jungkook. Please complete it by this week. If have any questions, feel free to ask me.'
          }),
          const MessageContainer(
            isUserMessage: false,
            message: {'text': 'Noted, sir.'},
            profileImage: 'assets/images/iu_pf.jpg',
          ),

          const ChatImageContainer(
              isUserMessage: true,
              imageUrl:
                  "https://cdn.prod.website-files.com/64760069e93084646c9ee428/64760069e93084646c9eeabb_6213b75e61ab1b3b14652ad3_outil-no-code-figma.png"),
          const MessageContainer(
            isUserMessage: true,
            message: {'text': 'Please allow access to Jungkook, Jimin-ssi'},
          ),

          const MessageContainer(
            isUserMessage: false,
            message: {'text': 'Noted, sir.'},
            profileImage: 'assets/images/avatar5.jpg',
          ),

          /// ===================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUserMessage = message['isUserMessage'];

                return MessageContainer(
                    isUserMessage: isUserMessage, message: message);
              },
            ),
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
                    // Handle file attachment
                  },
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
