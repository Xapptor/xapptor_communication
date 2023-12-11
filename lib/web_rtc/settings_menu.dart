// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/video_dropdown_button.dart';

extension StateExtension on CallViewState {
  settings_menu({
    required Color background_color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.95,
        widthFactor: 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  show_settings.value = !show_settings.value;
                  setState(() {});
                },
              ),
            ),
            audio_dropdown_button(),
            video_dropdown_button(),
          ],
        ),
      ),
    );
  }
}
