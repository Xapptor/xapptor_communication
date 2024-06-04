// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/widgets/check_permission.dart';
import 'package:xapptor_communication/web_rtc/media/get_media_devices.dart';
import 'package:xapptor_ui/utils/get_platform_name.dart';
import 'package:xapptor_ui/utils/get_browser_name.dart';

extension StateExtension on CallViewState {
  check_permissions() async {
    String platform_name = get_platform_name();
    debugPrint("platform_name: $platform_name");

    String browser_name = await get_browser_name();
    debugPrint("browser_name: $browser_name");

    String camera_title = "You must give camera permission";
    String microphone_title = "You must give microphone permissions";
    String label_no = "Cancel";
    String label_yes = "Accept";

    await check_permission(
      platform_name: platform_name,
      browser_name: browser_name,
      context: context,
      title: camera_title,
      label_no: label_no,
      label_yes: label_yes,
      permission_type: Permission.camera,
      callback: (camera_granted) {
        Timer(Duration(milliseconds: camera_granted ? 0 : 1300), () async {
          await check_permission(
            platform_name: platform_name,
            browser_name: browser_name,
            context: context,
            title: microphone_title,
            label_no: label_no,
            label_yes: label_yes,
            permission_type: Permission.microphone,
            callback: (microphone_granted) async {
              if (camera_granted && microphone_granted) {
                await get_media_devices();
              } else {
                Navigator.pop(context);
              }
            },
          );
        });
      },
    );
  }
}
