// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/add_remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  init_video_renderers() {
    local_renderer.initialize();
    signaling.on_add_remote_stream = ((stream) async {
      add_remote_renderer(remote_renderers);
      await remote_renderers.value.last.video_renderer.initialize();
      remote_renderers.value.last.video_renderer.srcObject = stream;
      setState(() {});
    });
  }
}
