import 'package:flutter/material.dart';
import '../services/agora_service.dart';

class VoiceChatWidget extends StatefulWidget {
  final String channelName;
  final String userId;

  const VoiceChatWidget({
    Key? key,
    required this.channelName,
    required this.userId,
  }) : super(key: key);

  @override
  State<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends State<VoiceChatWidget> {
  late AgoraService _agoraService;
  bool _isMuted = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceChat();
  }

  Future<void> _initializeVoiceChat() async {
    _agoraService = AgoraService();
    await _agoraService.init();
    await _agoraService.joinChannel(widget.channelName, widget.userId);
    
    setState(() {
      _isConnected = true;
    });
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _agoraService.muteAudio(_isMuted);
  }

  Future<void> _leaveChannel() async {
    await _agoraService.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🎤 Voice Chat Active',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Channel: ${widget.channelName}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _toggleMute,
                backgroundColor: _isMuted ? Colors.red : Colors.green,
                mini: true,
                child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: _leaveChannel,
                backgroundColor: Colors.red,
                mini: true,
                child: const Icon(Icons.call_end),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isMuted ? 'Microphone: OFF' : 'Microphone: ON',
            style: TextStyle(
              color: _isMuted ? Colors.red : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }
}
