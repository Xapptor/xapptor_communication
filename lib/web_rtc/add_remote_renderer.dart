import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'model/remote_renderer.dart';

Future add_remote_renderer({
  required ValueNotifier<List<RemoteRenderer>> remote_renderers,
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
}
