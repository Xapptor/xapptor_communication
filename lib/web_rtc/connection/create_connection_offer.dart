// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
import 'package:xapptor_communication/web_rtc/connection/create_peer_connection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/model/connection.dart';
import 'dart:convert';

extension StateExtension on CallViewState {
  Future<String> create_connection_offer({
    String destination_user_id = '',
    required DocumentReference room_ref,
    required ValueNotifier<List<RemoteRenderer>> remote_renderers,
    required Function setState,
  }) async {
    DocumentReference connection_ref = room_ref.collection('connections').doc();
    debugPrint('New connection created: ${connection_ref.id}');

    await create_peer_connection(
      collection_name: 'source_candidates',
      connection_ref: connection_ref,
    );

    Connection connection = await _create_offer(
      connection_ref: connection_ref,
      destination_user_id: destination_user_id,
    );

    Timer(const Duration(seconds: 2), () {
      peer_connections.last.value.onTrack = (RTCTrackEvent event) {
        debugPrint('Got remote track: ${event.streams[0]}');

        event.streams[0].getTracks().forEach((track) {
          debugPrint('Add a track to the remoteStream: $track');
          debugPrint('CCO - Remote renderers length: ${remote_renderers.value.length}');
          remote_renderers.value.last.video_renderer.srcObject?.addTrack(track);
        });
      };
    });

    // Listening for remote session description below
    connection_ref.snapshots().listen((snapshot) async {
      //debugPrint('Got updated connection: ${snapshot.data()}');
      if (snapshot.exists) {
        Map<String, dynamic> connection_data = snapshot.data() as Map<String, dynamic>;

        if (connection_data['answer'] != null) {
          var answer = RTCSessionDescription(
            connection_data['answer']['sdp'],
            connection_data['answer']['type'],
          );

          debugPrint("Someone tried to connect");
          await peer_connections.last.value.setRemoteDescription(answer);
        }

        updating_last_remote_renderer(
          connection_data: connection_data,
        );
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    connection_ref.collection('destination_candidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;

          debugPrint('Got new remote ICE candidate: ${jsonEncode(data)}');
          peer_connections.last.value.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
    // Listen for remote ICE candidates above
    return connection.id;
  }

  Future<Connection> _create_offer({
    required DocumentReference connection_ref,
    required String destination_user_id,
  }) async {
    // Add code for creating a connection
    RTCSessionDescription offer = await peer_connections.last.value.createOffer();
    await peer_connections.last.value.setLocalDescription(offer);
    //debugPrint('Created offer: ${offer.toMap()}');

    Connection connection = Connection(
      id: connection_ref.id,
      created: DateTime.now(),
      source_user_id: widget.user_id,
      destination_user_id: destination_user_id,
      offer: ConnectionOfferAnswer.from_map(offer.toMap()),
    );

    await connection_ref.set(connection.to_json());
    String connection_id = connection_ref.id;

    debugPrint('New connection created with SDK offer. Connection ID: $connection_id');
    current_room_text = 'Current connection is $connection_id - You are the source!';
    // Created a connection
    return connection;
  }

  Future updating_last_remote_renderer({
    required Map<String, dynamic> connection_data,
  }) async {
    // Updating last remote renderer
    if (connection_data['destination_user_id'] != '') {
      User user = await get_user_from_id(connection_data['destination_user_id']);
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
