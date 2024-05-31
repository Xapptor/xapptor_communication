// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
import 'package:xapptor_communication/web_rtc/connection/create_connection_anwser.dart';
import 'package:xapptor_communication/web_rtc/connection/create_connection_offer.dart';
import 'package:xapptor_communication/web_rtc/model/connection.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/room/clean_the_room.dart';
import 'package:xapptor_communication/web_rtc/room/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/connection/listen_connections.dart';
import 'package:xapptor_router/update_path/update_path.dart';

extension StateExtension on CallViewState {
  call_join_room(String room_id) async {
    await join_room(
      room_id: widget.room_id.value,
      remote_renderers: remote_renderers,
      setState: setState,
    );
    in_a_call.value = true;

    DocumentSnapshot room_snap = await db.collection('rooms').doc(widget.room_id.value).get();

    room = ValueNotifier<Room>(Room.from_snapshot(room_snap.id, room_snap.data() as Map<String, dynamic>));

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
  }

  Future join_room({
    required String room_id,
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Function setState,
  }) async {
    DocumentReference room_ref = rooms_ref.doc(room_id);
    DocumentSnapshot room_snap = await room_ref.get();
    Room room = Room.from_snapshot(room_id, room_snap.data() as Map<String, dynamic>);

    List<Connection> connections = await room.connections();

    if (connections.length > 1) {
      create_pending_connections(
        connections: connections,
        room_ref: room_ref,
        remote_renderers: remote_renderers,
        setState: setState,
      );
    } else if (connections.length == 1) {
      if (connections.first.destination_user_id == '') {
        create_connection_anwser(
          connection: connections.first,
          room_ref: room_ref,
          setState: setState,
        );
      } else {
        create_pending_connections(
          connections: connections,
          room_ref: room_ref,
          remote_renderers: remote_renderers,
          setState: setState,
        );
      }
    }
  }

  create_pending_connections({
    required List<Connection> connections,
    required DocumentReference room_ref,
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Function setState,
  }) async {
    List<String> user_ids = get_users_ids_from_connection_list(connections);
    for (String user_id in user_ids) {
      await create_connection_offer(
        destination_user_id: user_id,
        room_ref: room_ref,
        remote_renderers: remote_renderers,
        setState: setState,
      );
    }
  }
}
