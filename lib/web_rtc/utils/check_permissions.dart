// ignore_for_file: use_build_context_synchronously

import 'package:permission_handler/permission_handler.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/widgets/check_permission.dart';
import 'package:xapptor_communication/web_rtc/media/get_media_devices.dart';

extension StateExtension on CallViewState {
  check_permissions() async {
    String message = "You must give the camera and microphone permissions";

    await check_permission(
      context: context,
      message: message,
      message_no: "Cancel",
      message_yes: "Accept",
      permission_type: Permission.camera,
      callback: (granted) {
        camera_permission_granted = granted;
        _call_get_media_devices(
          is_last_call: false,
        );
      },
    );
    await check_permission(
      context: context,
      message: message,
      message_no: "Cancel",
      message_yes: "Accept",
      permission_type: Permission.microphone,
      callback: (granted) {
        microphone_permission_granted = granted;
        _call_get_media_devices(
          is_last_call: true,
        );
      },
    );
  }

  _call_get_media_devices({
    required bool is_last_call,
  }) async {
    if (camera_permission_granted && microphone_permission_granted) {
      await get_media_devices();
    }
  }
}
