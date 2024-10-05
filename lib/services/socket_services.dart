import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController.broadcast();

  bool _isConnected = false;

  SocketService._internal();

  void connect(String url) {
    if (!_isConnected) {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      _channel?.stream.listen(
        (message) {
          _messageController.add(message);
        },
        onError: (error) {
          print("WebSocket error: $error");
        },
        onDone: () {
          print("WebSocket closed");
          _isConnected = false;
          _channel?.sink.close();
        },
      );
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  Stream<String> get messageStream => _messageController.stream;

  // Gracefully close WebSocket connection
  void disconnect() {
    if (_isConnected) {
      _channel?.sink.close();
      _isConnected = false;
      print("WebSocket disconnected.");
    }
  }

  bool shouldTriggerApiCall(String message) {
    return message.contains("updateChats"); // Customize this condition
  }
}
