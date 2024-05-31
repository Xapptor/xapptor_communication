import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

set_zoom({
  required ValueNotifier<RTCVideoRenderer> local_renderer,
  required double zoom,
}) {
  Helper.setZoom(
    local_renderer.value.srcObject!.getVideoTracks()[0],
    zoom,
  );
}
