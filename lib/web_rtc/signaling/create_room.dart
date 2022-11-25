import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/signaling/copy_to_clipboard.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/room.dart';
import 'signaling.dart';

extension CreateRoom on Signaling {
  Future<Room> create_room(BuildContext context) async {
    DocumentReference room_ref = rooms_ref.doc();
    room_id.value = room_ref.id;
    await create_connection_offer(
      room_ref: room_ref,
    );

    Room room = Room(
      id: room_ref.id,
      created: DateTime.now(),
      host_id: user_id,
    );
    await room_ref.set(room.to_json());

    copy_to_clipboard(
      data: room_ref.id,
      message: "Room ID copied to clipboard",
      context: context,
    );
    return room;
  }
}
