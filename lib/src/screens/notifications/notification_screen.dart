import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> notifications = [];
  String userToken = '';
  String userRole = '';
  late SocketService socketService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  // Load the user token asynchronously from SharedPreferences
  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      userToken = prefs.getString('token') ?? '';
      userRole = prefs.getString('role') ?? '';
    });

    // Initialize the socket service after getting the token
    socketService = SocketService();
    socketService.connectSocket(userToken);

    if (userRole == 'admin') {
      socketService.listenForAdminNotifications((data) {
        setStateIfMounted(() {
          notifications.insert(0, data['message']);
        });
      });
    } else {
      socketService.listenForUserNotifications((data) {
        setStateIfMounted(() {
          notifications.insert(0, data['message']);
        });
      });
    }

    await _fetchNotifications();
  }

  // Fetch notifications from the backend
  Future<void> _fetchNotifications() async {
    if (userToken.isEmpty) {
      print("User token is not available.");
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/notifications/get-notification'),
      headers: {
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> notificationData = json.decode(response.body)['data'];
      setStateIfMounted(() {
        notifications = notificationData
            .map((notification) => notification['message'] as String)
            .toList();
        isLoading = false;
      });
    } else {
      print('Failed to load notifications: ${response.statusCode}');
      setStateIfMounted(() {
        isLoading = false;
      });
    }
  }

  // Check if the widget is still mounted before calling setState
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    socketService.stopListeningForNotifications();
    socketService.stopListeningForUserNotifications();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text('No notifications yet'),
                )
              : ListView.separated(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(notifications[index]),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                ),
    );
  }
}

class SocketService {
  late IO.Socket socket;

  // Initialize the socket connection
  void connectSocket(String token) {
    // Create and configure the socket
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': token},
    });

    // Handle connection success
    socket.on('connect', (_) {
      print('Connected to the server.');
    });

    // Handle connection errors
    socket.on('connect_error', (data) {
      print('Connection failed: ${data.toString()}');
    });
  }

  // Listen for admin notifications
  void listenForAdminNotifications(
      void Function(Map<String, dynamic>) callback) {
    socket.on('adminNotification', (data) {
      print('Received admin notification: $data');
      callback(data);
    });
  }

  // Stop listening to all notifications
  void stopListeningForNotifications() {
    socket.off('adminNotification');
    print('Stopped listening to notifications.');
  }

  void listenForUserNotifications(
      void Function(Map<String, dynamic>) callback) {
    socket.on('userNotification', (data) {
      print('Received user notification: $data');
      callback(data);
    });
  }

  void stopListeningForUserNotifications() {
    socket.off('userNotification');
    print('Stopped listening to notifications.');
  }

  // Disconnect the socket
  void disconnectSocket() {
    stopListeningForNotifications();
    socket.disconnect();
    print('Socket disconnected.');
  }
}
