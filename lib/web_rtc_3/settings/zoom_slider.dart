import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Widget zoom_slider({
  required ValueNotifier<double> zoom,
  required RTCVideoRenderer local_video_renderer,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 20),
        child: const Text(
          "Video Zoom",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      Slider(
        value: zoom.value,
        max: 10,
        divisions: 10,
        label: "${zoom.value.round()}x",
        onChanged: (double value) {
          zoom.value = value;
          _set_zoom(
            local_video_renderer: local_video_renderer,
            zoom: zoom.value,
          );
        },
      ),
    ],
  );
}

_set_zoom({
  required RTCVideoRenderer local_video_renderer,
  required double zoom,
}) {
  Helper.setZoom(
    local_video_renderer.srcObject!.getVideoTracks()[0],
    zoom,
  );
}
