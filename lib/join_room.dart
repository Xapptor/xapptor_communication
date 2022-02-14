import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'register_peer_connection_listeners.dart';
import 'signaling.dart';

Future join_room({
  required String room_id,
  required RTCVideoRenderer remote_video,
  required Map<String, dynamic> configuration,
  required RTCPeerConnection? peer_connection,
  required MediaStream? local_stream,
  required MediaStream? remote_stream,
  required StreamStateCallback? on_add_remote_stream,
}) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentReference room_ref = db.collection('rooms').doc('$room_id');
  var room_snapshot = await room_ref.get();
  print('Got room ${room_snapshot.exists}');

  if (room_snapshot.exists) {
    print('Create PeerConnection with configuration: $configuration');
    peer_connection = await createPeerConnection(configuration);

    register_peer_connection_listeners(
      peer_connection: peer_connection,
      remote_stream: remote_stream,
      on_add_remote_stream: on_add_remote_stream,
    );

    local_stream?.getTracks().forEach((track) {
      peer_connection?.addTrack(track, local_stream);
    });

    // Code for collecting ICE candidates below
    var calleeCandidatesCollection = room_ref.collection('calleeCandidates');
    peer_connection.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      calleeCandidatesCollection.add(candidate.toMap());
    };
    // Code for collecting ICE candidate above

    peer_connection.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remote_stream?.addTrack(track);
      });
    };

    // Code for creating SDP answer below
    var data = room_snapshot.data() as Map<String, dynamic>;
    print('Got offer $data');
    var offer = data['offer'];
    await peer_connection.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );
    var answer = await peer_connection.createAnswer();
    print('Created Answer $answer');

    await peer_connection.setLocalDescription(answer);

    Map<String, dynamic> roomWithAnswer = {
      'answer': {'type': answer.type, 'sdp': answer.sdp}
    };

    await room_ref.update(roomWithAnswer);
    // Finished creating SDP answer

    // Listening for remote ICE candidates below
    room_ref.collection('callerCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;
        print(data);
        print('Got new remote ICE candidate: $data');
        peer_connection!.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      });
    });
  }
}
