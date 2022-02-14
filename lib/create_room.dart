import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'register_peer_connection_listeners.dart';
import 'signaling.dart';

Future<String> create_room({
  required RTCVideoRenderer remote_renderer,
  required Map<String, dynamic> configuration,
  required RTCPeerConnection? peer_connection,
  required MediaStream? local_stream,
  required MediaStream? remote_stream,
  required String? current_room_text,
  required StreamStateCallback? on_add_remote_stream,
}) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentReference room_ref = db.collection('rooms').doc();

  print('Create PeerConnection with configuration: $configuration');

  peer_connection = await createPeerConnection(configuration);

  register_peer_connection_listeners(
    peer_connection: peer_connection,
    remote_stream: remote_stream,
    on_add_remote_stream: on_add_remote_stream,
  );

  local_stream?.getTracks().forEach((track) {
    peer_connection!.addTrack(track, local_stream);
  });

  // Code for collecting ICE candidates below
  var caller_candidates_collection = room_ref.collection('callerCandidates');

  peer_connection.onIceCandidate = (RTCIceCandidate candidate) {
    print('Got candidate: ${candidate.toMap()}');
    caller_candidates_collection.add(candidate.toMap());
  };
  // Finish Code for collecting ICE candidate

  // Add code for creating a room
  RTCSessionDescription offer = await peer_connection.createOffer();
  await peer_connection.setLocalDescription(offer);
  print('Created offer: $offer');

  Map<String, dynamic> room_with_offer = {'offer': offer.toMap()};

  await room_ref.set(room_with_offer);
  var room_id = room_ref.id;
  print('New room created with SDK offer. Room ID: $room_id');
  current_room_text = 'Current room is $room_id - You are the caller!';
  // Created a Room

  peer_connection.onTrack = (RTCTrackEvent event) {
    print('Got remote track: ${event.streams[0]}');

    event.streams[0].getTracks().forEach((track) {
      print('Add a track to the remoteStream $track');
      remote_stream?.addTrack(track);
    });
  };

  // Listening for remote session description below
  room_ref.snapshots().listen((snapshot) async {
    print('Got updated room: ${snapshot.data()}');

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (peer_connection?.getRemoteDescription() != null &&
        data['answer'] != null) {
      var answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );

      print("Someone tried to connect");
      await peer_connection?.setRemoteDescription(answer);
    }
  });
  // Listening for remote session description above

  // Listen for remote Ice candidates below
  room_ref.collection('calleeCandidates').snapshots().listen((snapshot) {
    snapshot.docChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
        print('Got new remote ICE candidate: ${jsonEncode(data)}');
        peer_connection!.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      }
    });
  });
  // Listen for remote ICE candidates above

  return room_id;
}
