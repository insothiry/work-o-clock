import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Obx(() {
        final notifications = controller.notifications;

        return notifications.isEmpty
            ? const Center(child: Text('No notifications'))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notifications[index]),
                  );
                },
              );
      }),
    );
  }
}
