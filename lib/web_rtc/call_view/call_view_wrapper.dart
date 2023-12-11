// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/utils/keyboard_hider.dart';
import 'package:xapptor_ui/widgets/topbar.dart';

extension StateExtension on CallViewState {
  call_view_wrapper({
    required Widget child,
  }) {
    return KeyboardHider(
      callback: () {
        if (show_settings.value) {
          show_settings.value = false;
          show_info.value = false;
          setState(() {});
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: TopBar(
            context: context,
            background_color: widget.main_color,
            actions: [],
            has_back_button: true,
            custom_leading: null,
            logo_path: widget.logo_path,
          ),
          body: child,
        ),
      ),
    );
  }
}
