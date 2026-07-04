import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/session.dart';

class SessionService {
  late IO.Socket socket;
  static const String SERVER_URL = 'http://your-server.com';

  Future<void> init() async {
    socket = IO.io(SERVER_URL, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  Future<String> createSession(String hostId, String videoUrl) async {
    return Future.delayed(const Duration(seconds: 1), () {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final session = Session(
        sessionId: sessionId,
        hostId: hostId,
        videoUrl: videoUrl,
        participants: [hostId],
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      socket.emit('session_created', session.toJson());
      return sessionId;
    });
  }

  Future<void> joinSession(String sessionId, String userId) async {
    socket.emit('join_session', {
      'sessionId': sessionId,
      'userId': userId,
    });
  }

  void listenToSessionUpdates(Function(Session) onUpdate) {
    socket.on('session_update', (data) {
      final session = Session.fromJson(data);
      onUpdate(session);
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
