import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  Future<List<MediaDeviceInfo>> get_audio_devices() async {
    return (await _get_devices()).where((device) => device.kind == "audioinput").toList();
  }

  Future<List<MediaDeviceInfo>> get_video_devices() async {
    return (await _get_devices()).where((device) => device.kind == "videoinput").toList();
  }

  Future<List<MediaDeviceInfo>> _get_devices() async {
    return await navigator.mediaDevices.enumerateDevices();
  }

  Future get_media_devices({
    required Function callback,
  }) async {
    audio_devices.value = await get_audio_devices();
    video_devices.value = await get_video_devices();

    if (audio_devices.value.isNotEmpty) {
      current_audio_device.value = audio_devices.value[0].label;
      current_audio_device_id.value = audio_devices.value[0].deviceId;
    }
    if (video_devices.value.isNotEmpty) {
      int array_index = 0;
      if (video_devices.value.length > 1) {
        if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
          array_index = 1;
          mirror_local_renderer.value = true;
        }
      }
      current_video_device.value = video_devices.value[array_index].label;
      current_video_device_id.value = video_devices.value[array_index].deviceId;
    }
    callback();
  }
}
