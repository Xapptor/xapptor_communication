import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteRenderer {
  RTCVideoRenderer video_renderer;
  String call_id;

  RemoteRenderer({
    required this.video_renderer,
    required this.call_id,
  });
}
