// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/show_exit_alert.dart';
import 'package:xapptor_router/update_path/update_path.dart';

extension StateExtension on CallViewState {
  exit_from_room({
    required String message,
  }) {
    remote_renderers.value.clear();
    in_a_call.value = false;
    room_id_controller.clear();
    widget.room_id.value = "";
    setState(() {});
    show_exit_alert(
      context: context,
      message: message,
    );
    update_path('home/room');
  }
}
