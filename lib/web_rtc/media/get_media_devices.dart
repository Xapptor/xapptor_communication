// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/media/open_user_media.dart';

extension StateExtension on CallViewState {
  Future get_media_devices() async {
    List<MediaDeviceInfo> devices = await navigator.mediaDevices.enumerateDevices();
    audio_devices.value = devices.where((device) => device.kind == "audioinput").toList();
    video_devices.value = devices.where((device) => device.kind == "videoinput").toList();

    if (audio_devices.value.isNotEmpty) {
      current_audio_device.value = audio_devices.value[0].label;
      current_audio_device_id.value = audio_devices.value[0].deviceId;
    }
    if (video_devices.value.isNotEmpty) {
      int array_index = 0;
      if (video_devices.value.length > 1) {
        if (UniversalPlatform.isMobile) {
          array_index = 1;
          mirror_local_renderer.value = true;
        }
      }
      current_video_device.value = video_devices.value[array_index].label;
      current_video_device_id.value = video_devices.value[array_index].deviceId;
    }
    await open_user_media();
  }
}
