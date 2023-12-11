import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

extension StateExtension on Signaling {
  register_peer_connection_listeners() {
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

    peer_connections.last.value.onAddStream = (MediaStream stream) {
      debugPrint("Add remote stream");
      on_add_remote_stream?.call(stream);
      remote_streams.add(stream);
    };
  }
}
