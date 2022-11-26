import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/add_remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_anwser.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';

listen_connections({
  required Room room,
  required String user_id,
  required ValueNotifier<List<RemoteRenderer>> remote_renderers,
  required Function setState,
  required Signaling signaling,
  required Function clean_the_room,
  required Function({
    required BuildContext context,
    required String message,
  })
      exit_from_room,
  required ValueNotifier<StreamSubscription?> connections_listener,
  required BuildContext context,
}) {
  bool first_time = true;
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentReference room_ref = db.collection('rooms').doc(room.id);
  CollectionReference connections_ref = room_ref.collection("connections");

  // At first call "snapshots().listen" retrieve all docs in the collection
  connections_listener.value =
      connections_ref.snapshots().listen((event) async {
    if (!first_time) {
      if (event.docs.isEmpty) {
        if (user_id == room.host_id) {
          clean_the_room();
        } else {
          exit_from_room(
            context: context,
            message: "The host closed the room",
          );
        }
      } else {
        event.docChanges.forEach((element) {
          //
          // If a new document is added to the collection
          if (element.type == DocumentChangeType.added) {
            print('Connection_added');
            Connection connection = Connection.from_snapshot(
                element.doc.id, element.doc.data() as Map<String, dynamic>);

            //
            // Check if the new connection is for me
            if (user_id == connection.destination_user_id) {
              print('new_connection_is_for_me');

              signaling.create_connection_anwser(
                connection: connection,
                room_ref: room_ref,
                callback: () {
                  _add_remote_renderer(
                    remote_renderers: remote_renderers,
                    connection: connection,
                  );
                },
              );
            }
          }
          //
          // If a  document is removed to the collection
          else if (element.type == DocumentChangeType.removed) {
            remote_renderers.value.removeWhere((remote_renderer) =>
                remote_renderer.connection_id == element.doc.id);
          }
          setState(() {});
        });
      }
    } else {
      first_time = false;
    }
  });
}

_add_remote_renderer({
  required ValueNotifier<List<RemoteRenderer>> remote_renderers,
  required Connection connection,
}) {
  if (remote_renderers.value.length == 0) {
    add_remote_renderer(remote_renderers);
  }
  remote_renderers.value.last.connection_id = connection.id;
  print("connection_id: ${connection.id}");
}
