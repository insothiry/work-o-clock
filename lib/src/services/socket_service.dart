import 'package:socket_io_client/socket_io_client.dart' as IO;

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

    // Listen for custom notifications
    socket.onAny((event, data) {
      print('Event: $event, Data: $data');
    });
  }

  // Disconnect the socket
  void disconnectSocket() {
    socket.disconnect();
    print('Socket disconnected.');
  }
}
