import 'package:flutter/material.dart';
import 'package:work_o_clock/src/screens/chat/group_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample chat data
    final List<Chat> chats = [
      Chat(
          title: "Meeting 17 Oct 2024",
          lastMessage: "Hey, how are you?",
          time: "10:30 AM"),
      Chat(
          title: "ABC Project",
          lastMessage: "Are we still on for tonight?",
          time: "9:45 AM"),
      Chat(
          title: "ITE Year 4 Project Defense",
          lastMessage: "See you at the meeting!",
          time: "8:15 AM"),
      Chat(
          title: "Project Practicum Presentation",
          lastMessage: "Let’s catch up!",
          time: "Yesterday"),
      Chat(
          title: "Entrepreneur Group 12",
          lastMessage: "Happy Birthday!",
          time: "Last week"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options action
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                chat.title[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(chat.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat.lastMessage),
            trailing:
                Text(chat.time, style: const TextStyle(color: Colors.grey)),
            onTap: () {
              // Navigate to the group chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(
                    chatTitle: chat.title,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Chat {
  final String title;
  final String lastMessage;
  final String time;

  Chat({
    required this.title,
    required this.lastMessage,
    required this.time,
  });
}
