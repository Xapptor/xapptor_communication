// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'model/remote_renderer.dart';

extension StateExtension on CallViewState {
  Future add_remote_renderer({
    required MediaStream? stream,
  }) async {
    RTCVideoRenderer video_renderer = RTCVideoRenderer();
    await video_renderer.initialize();
    video_renderer.srcObject = stream ?? await createLocalMediaStream('key');

    remote_renderers.value.add(
      RemoteRenderer(
        video_renderer: video_renderer,
        connection_id: "",
        user_id: "",
        user_name: "",
      ),
    );
    debugPrint("remote_renderers_length ${remote_renderers.value.length}");
    setState(() {});
  }
}
