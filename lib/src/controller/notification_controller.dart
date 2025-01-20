import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotificationController extends GetxController {
  var notifications = <String>[].obs; // Observable list of notifications
  final IO.Socket _socket;

  NotificationController(this._socket);

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _socket.on('leaveRequestNotification', (data) {
      final message = data['message'] as String;
      notifications.add(message);
    });
  }

  @override
  void onClose() {
    _socket.off('leaveRequestNotification');
    super.onClose();
  }
}
