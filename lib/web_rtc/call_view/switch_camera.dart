import 'package:flutter_webrtc/flutter_webrtc.dart';

switch_camera({
  required RTCVideoRenderer local_renderer,
  required String video_device_id,
  required MediaStream? local_stream,
}) {
  Helper.switchCamera(
    local_renderer.srcObject!.getVideoTracks()[0],
    video_device_id,
    local_stream,
  );
}
