import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallWidget extends StatefulWidget {
  final String channelName;
  final String userId;
  final String appId;

  const VideoCallWidget({
    super.key,
    required this.channelName,
    required this.userId,
    required this.appId,
  });

  @override
  State<VideoCallWidget> createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  late RtcEngine agoraEngine;
  bool _isVideoEnabled = false;
  bool _isAudioEnabled = false;
  final List<int> _remoteUserIds = [];
  int? _localUserId;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Create engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
      RtcEngineContext(appId: widget.appId),
    );

    // Enable video and audio
    await agoraEngine.enableVideo();
    await agoraEngine.enableAudio();

    // Setup callbacks
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUserIds.add(remoteUid);
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUserIds.remove(remoteUid);
          });
        },
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() {
            _localUserId = widget.userId.hashCode;
          });
        },
      ),
    );

    // Join channel
    await agoraEngine.joinChannel(
      token: '',
      channelId: widget.channelName,
      uid: widget.userId.hashCode,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );

    setState(() {
      _isVideoEnabled = true;
      _isAudioEnabled = true;
    });
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await agoraEngine.enableLocalVideo(_isVideoEnabled);
  }

  Future<void> _toggleAudio() async {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    await agoraEngine.muteLocalAudioStream(!_isAudioEnabled);
  }

  Future<void> _switchCamera() async {
    await agoraEngine.switchCamera();
  }

  Future<void> _leaveChannel() async {
    await agoraEngine.leaveChannel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Local video
        Container(
          color: Colors.black,
          child: _localUserId != null
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraEngine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        // Remote videos
        if (_remoteUserIds.isNotEmpty)
          Positioned(
            bottom: 120,
            left: 16,
            child: SizedBox(
              width: 120,
              height: 160,
              child: Container(
                color: Colors.black,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraEngine,
                    canvas: VideoCanvas(uid: _remoteUserIds[0]),
                  ),
                ),
              ),
            ),
          ),
        // Controls
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _toggleAudio,
                  backgroundColor: _isAudioEnabled ? Colors.blue : Colors.red,
                  mini: true,
                  child: Icon(
                    _isAudioEnabled ? Icons.mic : Icons.mic_off,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoEnabled ? Colors.blue : Colors.red,
                  mini: true,
                  child: Icon(
                    _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _switchCamera,
                  backgroundColor: Colors.blue,
                  mini: true,
                  child: const Icon(Icons.switch_camera),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _leaveChannel,
                  backgroundColor: Colors.red,
                  mini: true,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    agoraEngine.release();
    super.dispose();
  }
}
