// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

extension StateExtension on CallViewState {
  Widget zoom_slider() {
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
            setState(() {});
            _set_zoom(
              local_renderer: local_renderer,
              zoom: zoom.value,
            );
          },
        ),
      ],
    );
  }

  _set_zoom({
    required ValueNotifier<RTCVideoRenderer> local_renderer,
    required double zoom,
  }) {
    Helper.setZoom(
      local_renderer.value.srcObject!.getVideoTracks()[0],
      zoom,
    );
  }
}
