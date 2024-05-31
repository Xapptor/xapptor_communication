// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/connection/create_connection_offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_ui/utils/copy_to_clipboard.dart';
import 'package:xapptor_logic/generate_random_id.dart';
import 'package:xapptor_communication/web_rtc/room/clean_the_room.dart';
import 'package:xapptor_communication/web_rtc/room/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/connection/listen_connections.dart';
import 'package:xapptor_router/update_path/update_path.dart';

String ROOM_CREATOR_RANDOM_ID = "";

extension StateExtension on CallViewState {
  call_create_room() async {
    if (room_id_controller.text.isEmpty) {
      room = ValueNotifier<Room>(
        await create_room(
          context: context,
          remote_renderers: remote_renderers,
          setState: setState,
        ),
      );

      widget.room_id.value = room!.value.id;

      in_a_call.value = true;

      if (context.mounted) {
        listen_connections(
          setState: setState,
          clean_the_room: clean_the_room,
          exit_from_room: exit_from_room,
          context: context,
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

  Future<Room> create_room({
    required BuildContext context,
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Function setState,
  }) async {
    DocumentReference room_ref = rooms_ref.doc();
    room_id.value = room_ref.id;

    if (context.mounted) {
      copy_to_clipboard(
        data: room_ref.id,
        message: "Room ID copied to clipboard",
        context: context,
      );
    }

    await create_connection_offer(
      room_ref: room_ref,
      remote_renderers: remote_renderers,
      setState: setState,
    );

    ROOM_CREATOR_RANDOM_ID = generate_random_id();

    Room room = Room(
      id: room_ref.id,
      created: DateTime.now(),
      host_id: widget.user_id,
      temp_id: ROOM_CREATOR_RANDOM_ID,
    );

    Map room_json = room.to_json();
    room_json['created'] = FieldValue.serverTimestamp();
    await room_ref.set(room_json);

    return room;
  }
}
