import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/controller/notification_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = Get.find<NotificationController>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print("User token is not available.");
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/notifications/get-notification'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      final List<String> messages =
          data.map<String>((n) => n['message'] as String).toList();
      controller.setNotifications(messages);
    } else {
      print('Failed to load notifications: ${response.statusCode}');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final notifications = controller.notifications;
              if (notifications.isEmpty) {
                return const Center(child: Text("No notifications"));
              }
              return ListView.separated(
                itemCount: notifications.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notifications[i]),
                ),
                separatorBuilder: (_, __) => const Divider(),
              );
            }),
    );
  }
}
