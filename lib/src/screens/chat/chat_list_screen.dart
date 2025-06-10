import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/screens/chat/chat_screen.dart';
import 'package:work_o_clock/src/screens/chat/create_chat_screen.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/base_search_bar.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;

  const ChatListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> chats = [];
  String? username;
  Map<String, dynamic>? adminUser;

  @override
  void initState() {
    super.initState();
    fetchChatList();
    fetchAdmin();
    SocketService().onNewChatEntry = () {
      fetchChatList();
    };
    _loadUsername();
  }

  void _loadUsername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final storedUsername = preferences.getString('userName');
    if (storedUsername != null) {
      setState(() {
        username = storedUsername;
      });
    }
  }

  Future<void> fetchAdmin() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/get-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final adminData = json.decode(response.body)['admin'];
        setState(() => adminUser = adminData);
      }
    } catch (e) {
      debugPrint('Error fetching admin: $e');
    }
  }

  Future<void> fetchChatList() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3003/api/chatList/getChatList?user_id=${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => chats = List.from(data['data']));
      }
    } catch (e) {
      debugPrint('Error fetching chat list: $e');
    }
  }

  Future<void> _onRefresh() async {
    await fetchChatList();
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.tryParse(timestamp);
    if (dateTime == null) return '';
    final now = DateTime.now();
    final isToday = now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
    return isToday
        ? DateFormat('hh:mm a').format(dateTime)
        : DateFormat('MMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Edit',
                style: TextStyle(color: BaseColors.primaryColor)),
          ),
        ],
        centerTitle: true,
        title:
            const Text('Chats', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: Column(
        children: [
          const BaseSearchBar(),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  if (adminUser != null) _buildAdminChatCard(),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 10),
                    child: Text('Employee Chats',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  ...(chats.isEmpty
                      ? [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Center(
                                child: Text('No messages yet',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey))),
                          )
                        ]
                      : chats
                          .where((chat) =>
                              chat['receiver_id'] != adminUser?['_id'])
                          .map((chat) => _buildChatItem(chat))
                          .toList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BaseColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Get.to(CreateChatScreen(currentUserId: widget.userId));
        },
      ),
    );
  }

  Widget _buildAdminChatCard() {
    final adminChat = chats.firstWhere(
      (chat) => chat['receiver_id'] == adminUser?['_id'],
      orElse: () => null,
    );

    final lastMessage =
        adminChat?['last_message'] ?? "Welcome! How can we help?";
    final lastTimestamp = adminChat?['last_message_timestamp'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/logos/work-logo.png'),
            backgroundColor: Colors.white,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${adminUser!['name']} (Admin)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                formatTimestamp(lastTimestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          onTap: () {
            Get.to(() => ChatScreen(
                  senderId: widget.userId,
                  senderName: username ?? 'unknown',
                  receiverId: adminUser!['_id'],
                  receiverName: adminUser!['name'],
                ));
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final int unreadCount = chat['unread_count'] ?? 0;

    return Column(
      children: [
        ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg'),
                radius: 25,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            chat['name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(chat['last_message'] ?? 'No message yet'),
          trailing: Text(
            formatTimestamp(chat['last_message_timestamp']),
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            Get.to(() => ChatScreen(
                  senderId: widget.userId,
                  senderName: username ?? 'unknown',
                  receiverId: chat['receiver_id'],
                  receiverName: chat['name'] ?? '',
                ));
          },
        ),
        const Divider(indent: 80, height: 1),
      ],
    );
  }
}
