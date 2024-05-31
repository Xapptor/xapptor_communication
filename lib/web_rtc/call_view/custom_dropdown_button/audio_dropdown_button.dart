// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/media/call_open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/custom_dropdown_button/custom_dropdown_button.dart';

extension StateExtension on CallViewState {
  CustomDropdownButton audio_dropdown_button({
    Color? text_color = Colors.black,
  }) {
    return CustomDropdownButton(
      value: current_audio_device.value,
      on_changed: (new_value) {
        current_audio_device.value = new_value;
        current_audio_device_id.value = audio_devices.value.firstWhere((device) => device.label == new_value).deviceId;

        local_renderer.value.srcObject?.getAudioTracks().forEach((audio_track) {
          audio_track.stop();
        });
        call_open_user_media();
      },
      items: audio_devices.value.map((e) => e.label).toList(),
      title: widget.text_list[0],
      text_color: text_color,
    );
  }
}
