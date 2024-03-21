// ignore_for_file: use_build_context_synchronously

import 'package:xapptor_communication/web_rtc/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

extension StateExtension on Signaling {
  Future hang_up({
    required BuildContext context,
    required ValueNotifier<Room> room,
    required String user_id,
    required ValueNotifier<StreamSubscription?> connections_listener,
    required Function exit_from_room,
  }) async {
    String content = "Are you sure you want to hang up?";

    if (room.value.temp_id == ROOM_CREATOR_RANDOM_ID) {
      content += "\nYou are the room creator and this action will close the room for everyone.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hang Up"),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Hang Up"),
              onPressed: () async {
                Navigator.of(context).pop();
                await perform_hang_up(
                  context: context,
                  room: room,
                  user_id: user_id,
                  connections_listener: connections_listener,
                  exit_from_room: exit_from_room,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future perform_hang_up({
    required BuildContext context,
    required ValueNotifier<Room> room,
    required String user_id,
    required ValueNotifier<StreamSubscription?> connections_listener,
    required Function exit_from_room,
  }) async {
    await connections_listener.value!.cancel();

    exit_from_room();

    if (room_id.value != null) {
      for (var remote_stream in remote_streams) {
        remote_stream.getTracks().forEach((track) => track.stop());
      }
      for (var peer_connection in peer_connections) {
        peer_connection.value.close();
      }

      DocumentReference room_ref = rooms_ref.doc(room_id.value);
      DocumentSnapshot room_snap = await room_ref.get();
      Room room = Room.from_snapshot(room_id.value!, room_snap.data() as Map<String, dynamic>);

      List<Connection> connections = await room.connections();

      connections.asMap().forEach((index, connection) async {
        if (connection.source_user_id == user_id || connection.destination_user_id == user_id) {
          DocumentReference connection_ref = room_ref.collection('connections').doc(connection.id);

          await _delete_connection_candidates(
            connection_ref: connection_ref,
          );
          await connection_ref.delete();

          if (room.host_id == user_id && index == connections.length - 1 && ROOM_CREATOR_RANDOM_ID == room.temp_id) {
            await room_ref.delete();
          }
        }
      });

      for (var remote_stream in remote_streams) {
        remote_stream.dispose();
      }
    }
  }

  Future _delete_connection_candidates({
    required DocumentReference connection_ref,
  }) async {
    await connection_ref.collection('source_candidates').get().then((value) async {
      for (DocumentSnapshot candidate_snap in value.docs) {
        await candidate_snap.reference.delete();
      }
    });
    await connection_ref.collection('destination_candidates').get().then((value) async {
      for (DocumentSnapshot candidate_snap in value.docs) {
        await candidate_snap.reference.delete();
      }
    });
  }
}
