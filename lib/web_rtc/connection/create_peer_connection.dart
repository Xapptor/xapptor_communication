import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/peer_connection.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  // MARK: Create Peer Connection
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
    _register_peer_connection_listeners();

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

  // MARK: Peer Connection Listeners

  _register_peer_connection_listeners() {
    peer_connections.last.value.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peer_connections.last.value.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state change: $state');
    };

    peer_connections.last.value.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state change: $state');
    };

    peer_connections.last.value.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE connection state change: $state');
    };

    // *Deprecated* Use onTrack instead
    // peer_connections.last.value.onAddStream = (MediaStream stream) {
    //   print('__onAddStream_');
    //   on_add_remote_stream?.call(stream);
    // };

    peer_connections.last.value.onTrack = (RTCTrackEvent event) {
      on_add_remote_stream?.call(event.streams[0]);
    };
  }
}
