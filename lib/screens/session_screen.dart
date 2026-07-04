import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'video_player_widget.dart';
import 'voice_chat_widget.dart';

class SessionScreen extends StatefulWidget {
  final String userId;
  final String? sessionId;
  final bool isHost;

  const SessionScreen({
    Key? key,
    required this.userId,
    this.sessionId,
    required this.isHost,
  }) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late SessionService _sessionService;
  String? _currentSessionId;
  List<String> _participants = [];
  bool _voiceChatEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() async {
    _sessionService = SessionService();
    await _sessionService.init();

    if (widget.isHost) {
      _currentSessionId = await _sessionService.createSession(
        widget.userId,
        'https://www.commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4',
      );
      setState(() {
        _participants = [widget.userId];
      });
    } else {
      _currentSessionId = widget.sessionId;
      await _sessionService.joinSession(_currentSessionId!, widget.userId);
    }

    _sessionService.listenToSessionUpdates((session) {
      setState(() {
        _participants = session.participants;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Watch Session'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VideoPlayerWidget(
              videoUrl: 'https://www.commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4',
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session ID: $_currentSessionId',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Participants (${_participants.length}):',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._participants
                            .map((p) => Text('• $p', style: const TextStyle(fontSize: 11)))
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_voiceChatEnabled)
                    VoiceChatWidget(
                      channelName: _currentSessionId ?? 'default',
                      userId: widget.userId,
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Session Controls:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildControlButton(
                        _voiceChatEnabled ? Icons.mic : Icons.mic_none,
                        _voiceChatEnabled ? 'Stop Voice' : 'Start Voice',
                        _voiceChatEnabled ? Colors.red : Colors.blue,
                        () {
                          setState(() {
                            _voiceChatEnabled = !_voiceChatEnabled;
                          });
                        },
                      ),
                      _buildControlButton(
                        Icons.videocam,
                        'Camera',
                        Colors.blue,
                        () {},
                      ),
                      _buildControlButton(
                        Icons.chat,
                        'Chat',
                        Colors.blue,
                        () {},
                      ),
                      _buildControlButton(
                        Icons.exit_to_app,
                        'Leave',
                        Colors.red,
                        () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sessionService.disconnect();
    super.dispose();
  }
}
