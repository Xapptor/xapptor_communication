import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_peer_connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension JoinRoom on Signaling {
  Future<Room?> join_room({
    required String room_id,
  }) async {
    DocumentReference room_ref = rooms_ref.doc(room_id);
    DocumentSnapshot room_snap = await room_ref.get();
    Room room =
        Room.from_snapshot(room_id, room_snap.data() as Map<String, dynamic>);

    List<Connection> connections = room.connections;
    String connection_id = connections
        .firstWhere((element) => element.destination_user_id == '')
        .id;

    DocumentReference connection_ref = connections_ref.doc(connection_id);
    DocumentSnapshot connection_snap = await connection_ref.get();
    Map<String, dynamic> connection_data =
        connection_snap.data() as Map<String, dynamic>;

    print('Got connection ${connection_snap.exists}');

    if (connection_snap.exists) {
      this.room_id = room_id;

      await create_peer_connection(
        collection_name: 'destination_candidates',
        connection_ref: connection_ref,
      );

      peer_connection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remote_stream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      print('Got offer $connection_data');
      var offer = connection_data['offer'];
      await peer_connection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peer_connection!.createAnswer();
      print('Created Answer $answer');

      await peer_connection!.setLocalDescription(answer);

      await connection_ref.update({
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        }
      });
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      room_ref.collection('source_candidates').snapshots().listen((snapshot) {
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

      var new_connections = connections;
      new_connections
          .firstWhere((element) => element.id == connection_id)
          .destination_user_id = user_id;

      var new_connections_json = new_connections.map((e) => e.to_json());
      room_ref.update({
        'connections': new_connections_json,
      });

      return room;
    }
  }
}
