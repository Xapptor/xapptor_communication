// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/signaling/open_user_media.dart';

extension StateExtension on CallViewState {
  Future call_open_user_media() async {
    RTCVideoRenderer? remote_renderer;
    if (remote_renderers.value.isNotEmpty) {
      remote_renderer = remote_renderers.value.first.video_renderer;
    }
    await signaling.open_user_media(
      local_renderer: local_renderer,
      remote_renderer: remote_renderer,
      audio_device_id: current_audio_device_id.value,
      video_device_id: current_video_device_id.value,
      enable_audio: enable_audio.value,
      enable_video: enable_video.value,
      setState: setState,
    );
  }
}
