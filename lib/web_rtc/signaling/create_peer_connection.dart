import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/peer_connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/register_peer_connection_listeners.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
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

    print('create_peer_connection__');

    local_renderer.value.srcObject?.getTracks().forEach((track) {
      print('create_peer_connection__&');

      peer_connections.last.value.addTrack(track, local_renderer.value.srcObject!);
    });

    var candidates_collection = connection_ref.collection(collection_name);

    peer_connections.last.value.onIceCandidate = (RTCIceCandidate candidate) {
      //debugPrint('onIceCandidate: ${candidate.toMap()}');
      candidates_collection.add(candidate.toMap());
    };
  }
}
