import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'remote_renderer.dart';

add_remote_renderer(ValueNotifier<List<RemoteRenderer>> remote_renderers) {
  RTCVideoRenderer video_renderer = RTCVideoRenderer();
  video_renderer.initialize();
  remote_renderers.value.add(
    RemoteRenderer(
      video_renderer: video_renderer,
      call_id: "",
    ),
  );
  print("remote_renderers_length ${remote_renderers.value.length}");
}
