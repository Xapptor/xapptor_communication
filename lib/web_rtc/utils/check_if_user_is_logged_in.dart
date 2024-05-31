import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/renderer/init_video_renderers.dart';
import 'package:xapptor_communication/web_rtc/room/join_room.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart' as communication_user_model;
import 'package:xapptor_communication/web_rtc/utils/check_permissions.dart';
import 'package:xapptor_router/get_last_path_segment.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension StateExtension on CallViewState {
  check_if_user_is_logged_in() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      widget.user_id = user.uid;
      communication_user_model.User communication_user = await communication_user_model.get_user_from_id(user.uid);
      widget.user_name = communication_user.name;

      init_video_renderers();

      if (widget.room_id.value == '') {
        widget.room_id.value = get_last_path_segment();
      }

      if (widget.room_id.value != "" && widget.room_id.value != "room" && widget.room_id.value.length > 6) {
        join_room(widget.room_id.value);
      }

      await check_permissions();
    } else {
      Navigator.pop(context);
    }
  }
}
