// ignore_for_file: invalid_use_of_protected_member

import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  video_dropdown_button_callback(String new_value) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      if (new_value.toLowerCase().contains("back")) {
        mirror_local_renderer.value = false;
        setState(() {});
      } else if (new_value.toLowerCase().contains("front")) {
        mirror_local_renderer.value = true;
        setState(() {});
      }
    }
  }
}
