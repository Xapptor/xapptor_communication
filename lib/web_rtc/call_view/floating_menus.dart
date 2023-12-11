// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/video_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/video_dropdown_button_callback.dart';
import 'package:xapptor_communication/web_rtc/room_info.dart';
import 'package:xapptor_communication/web_rtc/settings_menu.dart';

extension StateExtension on CallViewState {
  List<Widget> floating_menus({
    required bool portrait,
  }) {
    return [
      show_settings.value
          ? FractionallySizedBox(
              heightFactor: portrait ? 0.8 : 0.7,
              widthFactor: portrait ? 0.9 : 0.5,
              child: SettingsMenu(
                background_color: Colors.blueGrey.withOpacity(0.9),
                audio_dropdown_button: audio_dropdown_button(),
                video_dropdown_button: video_dropdown_button(
                  callback: (new_value) => video_dropdown_button_callback(new_value),
                ),
                callback: () {
                  show_settings.value = !show_settings.value;
                  setState(() {});
                },
              ),
            )
          : Container(),
      show_info.value
          ? FractionallySizedBox(
              heightFactor: portrait ? 0.7 : 0.5,
              widthFactor: portrait ? 0.9 : 0.5,
              child: RoomInfo(
                background_color: Colors.blueGrey.withOpacity(0.9),
                main_color: widget.main_color,
                room_id: widget.room_id.value,
                call_base_url: widget.call_base_url,
                callback: () {
                  show_info.value = !show_info.value;
                  setState(() {});
                },
              ),
            )
          : Container(),
    ];
  }
}
