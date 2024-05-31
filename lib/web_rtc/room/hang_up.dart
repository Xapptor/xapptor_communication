// ignore_for_file: invalid_use_of_protected_member

import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/room/create_room.dart';
import 'package:xapptor_communication/web_rtc/model/connection.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/room/exit_from_room.dart';
import 'dart:async';

extension StateExtension on CallViewState {
  // MARK: Button Wdiget
  Widget hang_up_button() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () async {
        await hang_up(
            context: context,
            room: room!,
            user_id: widget.user_id,
            connections_listener: connections_listener,
            exit_from_room: () {
              String message = '';
              if (widget.user_id == room!.value.host_id) {
                message = 'You closed the room';
              } else {
                message = 'You exit the room';
              }

              if (context.mounted) {
                exit_from_room(
                  message: message,
                );
              }
              ROOM_CREATOR_RANDOM_ID = "";
              room = null;
              setState(() {});
            });
      },
      child: const Icon(Icons.call_end),
    );
  }

  // MARK: Main Function
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
                await _hang_up(
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

  Future _hang_up({
    required BuildContext context,
    required ValueNotifier<Room> room,
    required String user_id,
    required ValueNotifier<StreamSubscription?> connections_listener,
    required Function exit_from_room,
  }) async {
    await connections_listener.value!.cancel();

    exit_from_room();

    if (room_id.value != null) {
      for (var remote_renderer in remote_renderers.value) {
        remote_renderer.video_renderer.srcObject?.getTracks().forEach((track) => track.stop());
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

      for (var remote_renderer in remote_renderers.value) {
        await remote_renderer.video_renderer.srcObject?.dispose();
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
