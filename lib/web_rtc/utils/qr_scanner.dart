// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/media/open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';

extension StateExtension on CallViewState {
  qr_scanner() => QRScanner(
        descriptive_text: "Frame the QR code",
        update_qr_value: (new_value) {
          room_id_controller.text = new_value;
          show_qr_scanner.value = false;

          if (enable_video.value) open_user_media();
          setState(() {});
        },
        border_color: widget.main_color,
        border_radius: 4,
        border_length: 40,
        border_width: 8,
        cut_out_size: 300,
        button_linear_gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.4),
            Colors.green.withValues(alpha: 0.4),
          ],
        ),
        permission_title: "You must give the camera permission to capture QR codes",
        permission_label_no: "Cancel",
        permission_label_yes: "Accept",
        enter_code_text: "Enter your code",
        validate_button_text: "Validate",
        fail_message: "You have to enter a code",
        textfield_color: Colors.green,
        show_main_button: false,
        main_button_text: "Button",
        main_button_function: () => null,
      );
}
