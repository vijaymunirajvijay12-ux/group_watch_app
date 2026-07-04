import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = 'YOUR_AGORA_APP_ID'; // Replace with your App ID
  late RtcEngine agoraEngine;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));
    await agoraEngine.enableAudio();

    _isInitialized = true;
  }

  Future<void> joinChannel(String channelName, String userId) async {
    if (!_isInitialized) await init();

    await agoraEngine.joinChannel(
      token: '',
      channelId: channelName,
      uid: userId.hashCode,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await agoraEngine.leaveChannel();
  }

  Future<void> muteAudio(bool isMuted) async {
    await agoraEngine.muteLocalAudioStream(isMuted);
  }

  Future<void> dispose() async {
    await agoraEngine.release();
    _isInitialized = false;
  }

  RtcEngine getEngine() => agoraEngine;
}
