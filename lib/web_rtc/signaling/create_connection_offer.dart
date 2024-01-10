import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_peer_connection.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'dart:convert';
import 'signaling.dart';

extension StateExtension on Signaling {
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

    RTCPeerConnection peer_connection = peer_connections.firstWhere((element) => element.id == connection_ref.id).value;

    // Add code for creating a connection
    RTCSessionDescription offer = await peer_connection.createOffer();
    await peer_connection.setLocalDescription(offer);
    //debugPrint('Created offer: ${offer.toMap()}');

    Connection connection = Connection(
      id: connection_ref.id,
      created: DateTime.now(),
      source_user_id: user_id,
      destination_user_id: destination_user_id,
      offer: ConnectionOfferAnswer.from_map(offer.toMap()),
    );

    await connection_ref.set(connection.to_json());
    String connection_id = connection_ref.id;

    debugPrint('New connection created with SDK offer. Connection ID: $connection_id');
    current_room_text = 'Current connection is $connection_id - You are the source!';
    // Created a connection

    Timer(const Duration(seconds: 2), () {
      peer_connection.onTrack = (RTCTrackEvent event) {
        debugPrint('Got remote track: ${event.streams[0]}');

        event.streams[0].getTracks().forEach((track) {
          debugPrint('Add a track to the remoteStream $track');
          remote_streams.last.addTrack(track);
        });
      };
    });

    // Listening for remote session description below
    connection_ref.snapshots().listen((snapshot) async {
      //debugPrint('Got updated connection: ${snapshot.data()}');
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        if (data['answer'] != null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );

          debugPrint("Someone tried to connect");
          await peer_connection.setRemoteDescription(answer);
        }

        // Updating last remote renderer
        if (data['destination_user_id'] != '') {
          User user = await get_user_from_id(data['destination_user_id']);
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
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    connection_ref.collection('destination_candidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;

          debugPrint('Got new remote ICE candidate: ${jsonEncode(data)}');
          peer_connection.addCandidate(
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
    return connection_id;
  }
}
