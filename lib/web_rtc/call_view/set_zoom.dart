import 'package:flutter_webrtc/flutter_webrtc.dart';

set_zoom({
  required RTCVideoRenderer local_renderer,
  required double zoom,
}) {
  Helper.setZoom(
    local_renderer.srcObject!.getVideoTracks()[0],
    zoom,
  );
}
