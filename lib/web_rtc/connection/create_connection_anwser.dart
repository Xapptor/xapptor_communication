// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
import 'package:xapptor_communication/web_rtc/connection/create_peer_connection.dart';
import 'package:xapptor_communication/web_rtc/model/connection.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  create_connection_anwser({
    required Connection connection,
    required DocumentReference room_ref,
    required Function setState,
    Function? callback,
  }) async {
    CollectionReference connections_ref = room_ref.collection('connections');
    DocumentReference connection_ref = connections_ref.doc(connection.id);
    room_id.value = room_ref.id;

    await create_peer_connection(
      collection_name: 'destination_candidates',
      connection_ref: connection_ref,
    );

    await _create_answer(
      connection: connection,
      connection_ref: connection_ref,
    );

    Timer(const Duration(seconds: 2), () {
      peer_connections.last.value.onTrack = (RTCTrackEvent event) {
        debugPrint('Got remote track: ${event.streams[0]}');

        event.streams[0].getTracks().forEach((track) {
          debugPrint('Add a track to the remoteStream: $track');
          debugPrint('CCA - Remote renderers length: ${remote_renderers.value.length}');
          remote_renderers.value.last.video_renderer.srcObject?.addTrack(track);
        });
      };
    });

    // Listening for remote ICE candidates below
    connection_ref.collection('source_candidates').snapshots().listen((snapshot) {
      for (var doc_change in snapshot.docChanges) {
        if (doc_change.type == DocumentChangeType.added) {
          Map<String, dynamic> doc_change_data = doc_change.doc.data() as Map<String, dynamic>;

          RTCPeerConnection peer_connection =
              peer_connections.firstWhere((peer_connection) => peer_connection.id == connection_ref.id).value;

          debugPrint('Got new remote ICE candidate: ${jsonEncode(doc_change_data)}');
          peer_connection.addCandidate(
            RTCIceCandidate(
              doc_change_data['candidate'],
              doc_change_data['sdpMid'],
              doc_change_data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    await updating_last_remote_renderer(
      connection: connection,
    );

    if (callback != null) {
      callback();
    }
  }

  Future _create_answer({
    required Connection connection,
    required DocumentReference connection_ref,
  }) async {
    // Code for creating SDP answer below
    //debugPrint('Got offer ${connection.to_json()}');
    var offer = connection.offer;
    await peer_connections.last.value.setRemoteDescription(
      RTCSessionDescription(offer!.sdp, offer.type),
    );
    var answer = await peer_connections.last.value.createAnswer();
    debugPrint('Created Answer $answer');

    await peer_connections.last.value.setLocalDescription(answer);

    await connection_ref.update({
      'destination_user_id': widget.user_id,
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      }
    });
    // Finished creating SDP answer
  }

  Future updating_last_remote_renderer({
    required Connection connection,
  }) async {
    // Updating last remote renderer
    if (connection.source_user_id != '') {
      User user = await get_user_from_id(connection.source_user_id);
      Timer(const Duration(seconds: 1), () {
        if (remote_renderers.value.last.user_id == '') {
          remote_renderers.value.last
            ..user_id = user.id
            ..user_name = user.name;
          setState(() {});
        }
      });
    }
  }
}
