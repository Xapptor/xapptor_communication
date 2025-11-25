import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/media/open_user_media.dart';

set_local_video_renderer({
  required String new_value,
  required ValueNotifier<List<MediaDeviceInfo>> video_devices,
  required ValueNotifier<String> current_video_device,
  required ValueNotifier<String> current_video_device_id,
  required ValueNotifier<String> current_audio_device_id,
  required RTCVideoRenderer local_video_renderer,
  required ValueNotifier<bool> enable_video,
  required ValueNotifier<bool> enable_audio,
}) {
  current_video_device.value = new_value;
  current_video_device_id.value = video_devices.value.firstWhere((device) => device.label == new_value).deviceId;

  print("Current video device: ${current_video_device.value}");

  // local_video_renderer.srcObject?.getVideoTracks().forEach((element) {
  //   element.stop();
  // });

  open_user_media(
    current_video_device_id: current_video_device_id,
    current_audio_device_id: current_audio_device_id,
    local_video_renderer: local_video_renderer,
    enable_video: enable_video,
    enable_audio: enable_audio,
  );
}
