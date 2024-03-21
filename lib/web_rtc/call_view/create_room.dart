// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/clean_the_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/listen_connections.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_router/update_path/update_path.dart';

extension StateExtension on CallViewState {
  create_room() async {
    if (room_id_controller.text.isEmpty) {
      room = ValueNotifier<Room>(await signaling.create_room(
        context: context,
        remote_renderers: remote_renderers,
        setState: setState,
      ));

      widget.room_id.value = room!.value.id;

      in_a_call.value = true;

      if (context.mounted) {
        listen_connections(
          user_id: widget.user_id,
          remote_renderers: remote_renderers,
          setState: setState,
          signaling: signaling,
          clean_the_room: clean_the_room,
          exit_from_room: exit_from_room,
          connections_listener: connections_listener,
          context: context,
          room: room!,
        );
      }
      update_path('home/room/${widget.room_id.value}');
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Room ID must be empty to create a room',
          ),
        ),
      );
    }
  }
}
