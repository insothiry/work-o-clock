// Combined SocketService: Handles notification (port 3000) and chat (port 3003) without affecting existing notification logic.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket _notificationSocket;
  late IO.Socket _chatSocket;

  bool _isNotificationConnected = false;
  bool _isChatConnected = false;

  // Event handlers for chat
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onTyping;
  Function(Map<String, dynamic>)? onStopTyping;

  SocketService._internal();
  Function()? onNewChatEntry;

  Future<void> initNotificationSocket(String token,
      {Function()? onConnect}) async {
    if (_isNotificationConnected) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    final userId = pref.getString('userId');

    _notificationSocket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
    });

    _notificationSocket.on('connect', (_) {
      _isNotificationConnected = true;
      debugPrint('✅ Connected to notification socket');
      if (userId != null) {
        _notificationSocket.emit('join', userId);
        debugPrint('📢 Joined notification room: $userId');
      }
      if (onConnect != null) onConnect();
    });

    _notificationSocket.on('connect_error', (data) {
      debugPrint('❌ Notification socket connect error: $data');
    });
  }

  Future<void> initChatSocket(String token, {Function()? onConnect}) async {
    if (_isChatConnected) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    _chatSocket = IO.io('http://localhost:3003', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
    });

    _chatSocket.on('connect', (_) {
      _isChatConnected = true;
      debugPrint('✅ Connected to chat socket');
      if (userId != null) {
        _chatSocket.emit('join', userId);
        debugPrint('📢 Joined chat room: $userId');
      }
      if (onConnect != null) onConnect();
    });

    _chatSocket.on('receiveMessage', (data) {
      if (onMessageReceived != null) {
        onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });
    _chatSocket.on('typing', (data) {
      if (onTyping != null) onTyping!(Map<String, dynamic>.from(data));
    });
    _chatSocket.on('stopTyping', (data) {
      if (onStopTyping != null) onStopTyping!(Map<String, dynamic>.from(data));
    });

    _chatSocket.on('newChatListEntry', (data) {
      debugPrint("🆕 New chat list entry received: $data");
      if (onNewChatEntry != null) onNewChatEntry!();
    });

    _chatSocket.on('connect_error', (err) {
      debugPrint("❌ Chat socket error: $err");
    });
  }

  void sendMessage(
    String roomId,
    String senderId,
    String receiverId,
    String? content,
    String? media,
    String? senderName,
    String? receiverName,
  ) {
    _chatSocket.emit('sendMessage', {
      'room_id': roomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'media': media,
      'sender_name': senderName,
      'receiver_name': receiverName,
    });
  }

  void joinRoom(String roomId) {
    _chatSocket.emit('joinRoom', roomId);
  }

  void typing(String roomId) {
    _chatSocket.emit('typing', roomId);
  }

  void stopTyping(String roomId) {
    _chatSocket.emit('stopTyping', roomId);
  }

  void listenForAdminNotifications(
      void Function(Map<String, dynamic>) callback) {
    _notificationSocket.on('adminNotification', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  void listenForUserNotifications(
      void Function(Map<String, dynamic>) callback) {
    _notificationSocket.on('userNotification', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  void removeNotificationListeners() {
    _notificationSocket.off('adminNotification');
    _notificationSocket.off('userNotification');
  }

  void disconnectChat() {
    if (_isChatConnected) {
      _chatSocket.disconnect();
      _isChatConnected = false;
      debugPrint('🔌 Chat socket disconnected');
    }
  }

  void disconnectNotification() {
    if (_isNotificationConnected) {
      _notificationSocket.disconnect();
      _isNotificationConnected = false;
      debugPrint('🔌 Notification socket disconnected');
    }
  }

  bool get isNotificationConnected => _isNotificationConnected;
  bool get isChatConnected => _isChatConnected;
}
