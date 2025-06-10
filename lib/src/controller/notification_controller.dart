// lib/src/controllers/notification_controller.dart
import 'package:get/get.dart';

class NotificationController extends GetxController {
  RxList<String> notifications = <String>[].obs;

  void addNotification(String message) {
    notifications.insert(0, message);
  }

  void setNotifications(List<String> messages) {
    notifications.assignAll(messages);
  }
}
