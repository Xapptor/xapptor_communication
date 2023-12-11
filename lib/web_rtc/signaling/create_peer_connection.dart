import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/peer_connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/register_peer_connection_listeners.dart';
import 'signaling.dart';

extension StateExtension on Signaling {
  Future create_peer_connection({
    required String collection_name,
    required DocumentReference connection_ref,
  }) async {
    //debugPrint('Create PeerConnection with configuration: $configuration');
    peer_connections.add(
      PeerConnection(
        id: connection_ref.id,
        value: await createPeerConnection(configuration),
      ),
    );
    register_peer_connection_listeners();

    local_stream?.getTracks().forEach((track) {
      peer_connections.last.value.addTrack(track, local_stream!);
    });

    var candidates_collection = connection_ref.collection(collection_name);

    peer_connections.last.value.onIceCandidate = (RTCIceCandidate candidate) {
      //debugPrint('onIceCandidate: ${candidate.toMap()}');
      candidates_collection.add(candidate.toMap());
    };
  }
}
