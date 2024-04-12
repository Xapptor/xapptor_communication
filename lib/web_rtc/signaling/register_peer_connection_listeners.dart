import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
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
      print("add_remote_STREAM___");
      on_add_remote_stream?.call(stream);
      //remote_streams.add(stream);
    };

    peer_connections.last.value.onAddTrack = (MediaStream stream, MediaStreamTrack track) {
      print("add_remote_TRACK___");
      on_add_remote_stream?.call(stream);
    };
  }
}
