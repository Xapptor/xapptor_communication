import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'model/remote_renderer.dart';

add_remote_renderer(ValueNotifier<List<RemoteRenderer>> remote_renderers) {
  RTCVideoRenderer video_renderer = RTCVideoRenderer();
  video_renderer.initialize();
  remote_renderers.value.add(
    RemoteRenderer(
      video_renderer: video_renderer,
      connection_id: "",
      user_id: "",
      user_name: "",
    ),
  );
  debugPrint("remote_renderers_length ${remote_renderers.value.length}");
}
