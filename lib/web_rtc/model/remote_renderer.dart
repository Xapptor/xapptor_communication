import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteRenderer {
  RTCVideoRenderer video_renderer;
  String connection_id;
  String user_id;
  String user_name;

  RemoteRenderer({
    required this.video_renderer,
    required this.connection_id,
    required this.user_id,
    required this.user_name,
  });
}
