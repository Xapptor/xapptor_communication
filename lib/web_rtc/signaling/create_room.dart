import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/room.dart';
import 'signaling.dart';
import 'package:xapptor_ui/utils/copy_to_clipboard.dart';

extension CreateRoom on Signaling {
  Future<Room> create_room({
    required BuildContext context,
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Function setState,
  }) async {
    DocumentReference room_ref = rooms_ref.doc();
    room_id.value = room_ref.id;
    await create_connection_offer(
      room_ref: room_ref,
      remote_renderers: remote_renderers,
      setState: setState,
    );

    Room room = Room(
      id: room_ref.id,
      created: DateTime.now(),
      host_id: user_id,
    );

    Map room_json = room.to_json();
    room_json['created'] = FieldValue.serverTimestamp();
    await room_ref.set(room_json);

    if (context.mounted) {
      copy_to_clipboard(
        data: room_ref.id,
        message: "Room ID copied to clipboard",
        context: context,
      );
    }
    return room;
  }
}
