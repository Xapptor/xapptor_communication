import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_peer_connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'signaling.dart';

extension CreateConnectionAnswer on Signaling {
  create_connection_anwser({
    required Connection connection,
    required DocumentReference room_ref,
    Function? callback,
  }) async {
    CollectionReference connections_ref = room_ref.collection('connections');
    DocumentReference connection_ref = connections_ref.doc(connection.id);
    this.room_id.value = room_ref.id;

    await create_peer_connection(
      collection_name: 'destination_candidates',
      connection_ref: connection_ref,
    );

    peer_connections.last.value.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remote_streams.last.addTrack(track);
      });
    };

    // Code for creating SDP answer below
    //print('Got offer ${connection.to_json()}');
    var offer = connection.offer;
    await peer_connections.last.value.setRemoteDescription(
      RTCSessionDescription(offer!.sdp, offer.type),
    );
    var answer = await peer_connections.last.value.createAnswer();
    print('Created Answer $answer');

    await peer_connections.last.value.setLocalDescription(answer);

    await connection_ref.update({
      'destination_user_id': user_id,
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      }
    });
    // Finished creating SDP answer

    // Listening for remote ICE candidates below
    connection_ref
        .collection('source_candidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;

        var peer_connection = peer_connections
            .firstWhere(
                (peer_connection) => peer_connection.id == connection_ref.id)
            .value;

        print(data);
        print('Got new remote ICE candidate: $data');
        peer_connection.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      });
    });

    if (callback != null) {
      callback();
    }
  }
}
