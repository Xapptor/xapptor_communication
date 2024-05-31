// ignore_for_file: use_build_context_synchronously

import 'package:permission_handler/permission_handler.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/widgets/check_permission.dart';
import 'package:xapptor_communication/web_rtc/media/get_media_devices.dart';

extension StateExtension on CallViewState {
  check_permissions() async {
    bool camera_permission = await check_permission(
      context: context,
      message: "You must give the camera permission",
      message_no: "Cancel",
      message_yes: "Accept",
      permission_type: Permission.camera,
    );
    bool microphone_permission = await check_permission(
      context: context,
      message: "You must give the microphone permission",
      message_no: "Cancel",
      message_yes: "Accept",
      permission_type: Permission.microphone,
    );

    if (camera_permission && microphone_permission) {
      await get_media_devices();
    }
  }
}
