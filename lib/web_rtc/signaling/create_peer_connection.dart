import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/signaling/register_peer_connection_listeners.dart';
import 'signaling.dart';

extension CreatePeerConnection on Signaling {
  Future create_peer_connection({
    required String collection_name,
    required DocumentReference connection_ref,
  }) async {
    print('Create PeerConnection with configuration: $configuration');
    peer_connection = await createPeerConnection(configuration);
    register_peer_connection_listeners();

    local_stream?.getTracks().forEach((track) {
      peer_connection?.addTrack(track, local_stream!);
    });

    var candidates_collection = connection_ref.collection(collection_name);

    peer_connection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      candidates_collection.add(candidate.toMap());
    };
  }
}
