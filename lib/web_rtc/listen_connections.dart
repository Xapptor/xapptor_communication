import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/renderer/add_remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_anwser.dart';

extension StateExtension on CallViewState {
  listen_connections({
    required Function setState,
    required Function clean_the_room,
    required Function({
      required String message,
    }) exit_from_room,
    required BuildContext context,
  }) {
    bool first_time = true;
    DocumentReference room_ref = db.collection('rooms').doc(room?.value.id);
    CollectionReference connections_ref = room_ref.collection("connections");

    // At first call "snapshots().listen" retrieve all docs in the collection
    connections_listener.value = connections_ref.snapshots().listen((connections) async {
      if (!first_time) {
        if (connections.docs.isEmpty) {
          if (widget.user_id == room?.value.host_id && ROOM_CREATOR_RANDOM_ID == room?.value.temp_id) {
            clean_the_room();
          } else {
            exit_from_room(
              message: "The host closed the room",
            );
          }
        } else {
          for (var element in connections.docChanges) {
            //
            // If a new document is added to the collection
            if (element.type == DocumentChangeType.added) {
              debugPrint('Connection_added');
              Connection connection =
                  Connection.from_snapshot(element.doc.id, element.doc.data() as Map<String, dynamic>);

              //
              // Check if the new connection is for me
              if (widget.user_id == connection.destination_user_id) {
                debugPrint('new_connection_is_for_me');

                create_connection_anwser(
                  connection: connection,
                  room_ref: room_ref,
                  setState: setState,
                  callback: () {
                    _add_remote_renderer(
                      remote_renderers: remote_renderers,
                      connection: connection,
                      user_id: widget.user_id,
                      setState: setState,
                    );
                  },
                );
              }
            }
            //
            // If a  document is removed to the collection
            else if (element.type == DocumentChangeType.removed) {
              remote_renderers.value.removeWhere((remote_renderer) => remote_renderer.connection_id == element.doc.id);
              setState(() {});
            }
          }
        }
      } else {
        first_time = false;
      }
    });
  }

  _add_remote_renderer({
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Connection connection,
    required String user_id,
    required Function setState,
  }) async {
    if (remote_renderers.value.isEmpty) {
      await add_remote_renderer(
        stream: null,
      );
    }
    remote_renderers.value.last.connection_id = connection.id;
    String user_id = "";

    if (connection.source_user_id != user_id) {
      user_id = connection.source_user_id;
    } else if (connection.destination_user_id != user_id) {
      user_id = connection.destination_user_id;
    }

    remote_renderers.value.last.user_id = user_id;
    User user = await get_user_from_id(
      user_id,
    );
    remote_renderers.value.last.user_name = user.name;

    setState(() {});
    debugPrint("connection_id: ${connection.id}");
  }
}
