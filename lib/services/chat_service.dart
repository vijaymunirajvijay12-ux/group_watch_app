import "package:flutter/foundation.dart";
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatService {
  late io.Socket socket;
  List<ChatMessage> messages = [];
  Function(ChatMessage)? onMessageReceived;
  Function(List<String>)? onUsersUpdated;

  Future<void> init(String serverUrl, String userId, String sessionId) async {
    socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.on('connect', (_) {
      debugPrint('Connected to chat server');
      socket.emit('join_session', {'userId': userId, 'sessionId': sessionId});
    });

    socket.on('receive_message', (data) {
      final message = ChatMessage(
        userId: data['userId'],
        message: data['message'],
        timestamp: DateTime.parse(data['timestamp']),
      );
      messages.add(message);
      onMessageReceived?.call(message);
    });

    socket.on('users_updated', (data) {
      onUsersUpdated?.call(List<String>.from(data['users']));
    });

    socket.on('disconnect', (_) {
      debugPrint('Disconnected from chat server');
    });
  }

  void sendMessage(String userId, String message) {
    socket.emit('send_message', {
      'userId': userId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}

class ChatMessage {
  final String userId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.userId,
    required this.message,
    required this.timestamp,
  });
}
