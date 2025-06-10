import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:work_o_clock/src/screens/chat/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/widgets/base_search_bar.dart';

class CreateChatScreen extends StatefulWidget {
  final String currentUserId;

  const CreateChatScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  List<dynamic> employees = [];
  List<dynamic> filteredEmployees = [];
  String? currentUsername = '';
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchEmployees();
  }

  Future<void> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/api/users/get-user/${widget.currentUserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          currentUsername = data['user']['name'];
        });
      }
    } catch (e) {
      print("❌ Error fetching current user: $e");
    }
  }

  Future<void> fetchEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print('⚠️ No token found');
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/users/get-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] ?? [];

        final filtered =
            users.where((u) => u['_id'] != widget.currentUserId).toList();

        setState(() {
          employees = filtered;
          filteredEmployees = filtered; // 👈 initialize filtered list
          isLoading = false;
        });
      } else {
        print('❌ Failed with status ${response.statusCode}: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching employees: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterSearchResults(String query) {
    setState(() {
      filteredEmployees = employees.where((user) {
        final name = user['name']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
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
      appBar: AppBar(title: const Text("Start New Chat")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                BaseSearchBar(
                  hintText: 'Search Employee',
                  onChanged: _filterSearchResults,
                ),
                Expanded(
                  child: filteredEmployees.isEmpty
                      ? const Center(child: Text("No employees found."))
                      : ListView.builder(
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final user = filteredEmployees[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade300,
                                backgroundImage:
                                    (user['profileImage'] != null &&
                                            user['profileImage']
                                                .toString()
                                                .isNotEmpty)
                                        ? NetworkImage(user['profileImage'])
                                        : null,
                                child: (user['profileImage'] == null ||
                                        user['profileImage'].toString().isEmpty)
                                    ? Text(
                                        _getInitials(user['name']),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(user['name']),
                              subtitle: Text(user['email']),
                              onTap: () {
                                Get.to(() => ChatScreen(
                                      senderId: widget.currentUserId,
                                      senderName: currentUsername ?? 'unknown',
                                      receiverId: user['_id'],
                                      receiverName: user['name'],
                                    ));
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
