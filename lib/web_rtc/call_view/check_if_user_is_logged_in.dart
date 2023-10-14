// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/init_video_renderers.dart';
import 'package:xapptor_communication/web_rtc/call_view/join_room.dart';
import 'package:xapptor_communication/web_rtc/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart' as communication_user_model;
import 'package:xapptor_router/get_last_path_segment.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension StateExtension on CallViewState {
  check_if_user_is_logged_in() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      widget.user_id = user.uid;
      communication_user_model.User communication_user = await communication_user_model.get_user_from_id(user.uid);
      widget.user_name = communication_user.name;

      signaling.init(user_id: widget.user_id);
      init_video_renderers();

      if (widget.room_id.value == '') {
        widget.room_id.value = get_last_path_segment();
      }

      if (widget.room_id.value != "" && widget.room_id.value != "room" && widget.room_id.value.length > 6) {
        join_room(widget.room_id.value);
      }

      call_open_user_media().then((_) {
        get_media_devices(
          audio_devices: audio_devices,
          video_devices: video_devices,
          current_audio_device: current_audio_device,
          current_audio_device_id: current_audio_device_id,
          current_video_device: current_video_device,
          current_video_device_id: current_video_device_id,
          callback: () {
            setState(() {});
          },
        ).then((_) async {
          set_media_devices_enabled();
        });
      });
    } else {
      Navigator.pop(context);
    }
  }
}
