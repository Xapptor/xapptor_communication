// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/call_view/call_open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  set_local_renderer(String new_value) {
    current_video_device.value = new_value;
    current_video_device_id.value = video_devices.value.firstWhere((device) => device.label == new_value).deviceId;

    local_renderer.value.srcObject?.getVideoTracks().forEach((element) {
      element.stop();
    });
    call_open_user_media();
  }
}
