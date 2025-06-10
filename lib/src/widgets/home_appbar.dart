import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_o_clock/src/screens/chat/chat_list_screen.dart';
import 'package:work_o_clock/src/screens/notifications/notification_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String position;

  const HomeAppBar({
    Key? key,
    required this.name,
    required this.position,
  }) : super(key: key);

  /// Helper method to get initials from full name
  String getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';

    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    } else {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                getInitials(name),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: BaseColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  position,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: BaseColors.primaryColor,
        actions: [
          Row(children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble, color: Colors.white),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('userId');

                if (userId != null && userId.isNotEmpty) {
                  Get.to(() => ChatListScreen(userId: userId));
                } else {
                  Get.snackbar('Error', 'User ID not found in storage');
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Get.to(() => const NotificationScreen());
              },
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
