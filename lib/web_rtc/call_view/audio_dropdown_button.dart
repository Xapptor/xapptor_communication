// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/call_view/call_open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/custom_dropdown_button.dart';

extension StateExtension on CallViewState {
  CustomDropdownButton audio_dropdown_button() {
    return CustomDropdownButton(
      value: current_audio_device.value,
      on_changed: (new_value) {
        current_audio_device.value = new_value!;
        current_audio_device_id.value =
            audio_devices.value.firstWhere((element) => element.label == new_value).deviceId;

        local_renderer.srcObject?.getAudioTracks().forEach((element) {
          element.stop();
        });

        call_open_user_media();
        setState(() {});
      },
      items: audio_devices.value.map((e) => e.label).toList(),
      title: widget.text_list[0],
    );
  }
}
