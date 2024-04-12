// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/add_remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  init_video_renderers() {
    local_renderer.value.initialize();

    on_add_remote_stream = ((stream) async {
      print("on_add_remote_stream______");
      await add_remote_renderer(
        stream: stream,
      );
      setState(() {});
    });
  }
}
