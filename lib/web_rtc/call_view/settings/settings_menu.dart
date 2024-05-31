// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/custom_dropdown_button/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/custom_dropdown_button/video_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/zoom/zoom_slider.dart';

extension StateExtension on CallViewState {
  settings_menu({
    required Color background_color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                flex: 8,
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
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
            ],
          ),
          audio_dropdown_button(
            text_color: Colors.white,
          ),
          video_dropdown_button(
            text_color: Colors.white,
          ),
          if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) zoom_slider(),
        ],
      ),
    );
  }
}
