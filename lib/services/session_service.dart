import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/session.dart';

class SessionService {
  final DatabaseReference _sessionsRef =
      FirebaseDatabase.instance.ref('sessions');
  String? _currentSessionId;
  StreamSubscription<DatabaseEvent>? _subscription;

  Future<void> init() async {
    // Firebase is already initialized in main.dart
  }

  Future<String> createSession(String hostId, String videoUrl) async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final session = Session(
      sessionId: sessionId,
      hostId: hostId,
      videoUrl: videoUrl,
      participants: [hostId],
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _sessionsRef.child(sessionId).set(session.toJson());
    _currentSessionId = sessionId;
    return sessionId;
  }

  Future<void> joinSession(String sessionId, String userId) async {
    _currentSessionId = sessionId;
    final participantsRef =
        _sessionsRef.child(sessionId).child('participants');
    final snapshot = await participantsRef.get();

    List<String> participants = [];
    if (snapshot.exists && snapshot.value != null) {
      participants = List<String>.from(snapshot.value as List);
    }

    if (!participants.contains(userId)) {
      participants.add(userId);
      await participantsRef.set(participants);
    }
  }

  void listenToSessionUpdates(Function(Session) onUpdate) {
    if (_currentSessionId == null) return;
    _subscription =
        _sessionsRef.child(_currentSessionId!).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final session =
            Session.fromJson(Map<String, dynamic>.from(data as Map));
        onUpdate(session);
      }
    });
  }

  void disconnect() {
    _subscription?.cancel();
  }
}
