import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

register_peer_connection_listeners({
  required RTCPeerConnection? peer_connection,
  required MediaStream? remote_stream,
  required StreamStateCallback? on_add_remote_stream,
}) {
  peer_connection?.onIceGatheringState = (RTCIceGatheringState state) {
    print('ICE gathering state changed: $state');
  };

  peer_connection?.onConnectionState = (RTCPeerConnectionState state) {
    print('Connection state change: $state');
  };

  peer_connection?.onSignalingState = (RTCSignalingState state) {
    print('Signaling state change: $state');
  };

  peer_connection?.onIceGatheringState = (RTCIceGatheringState state) {
    print('ICE connection state change: $state');
  };

  peer_connection?.onAddStream = (MediaStream stream) {
    print("Add remote stream");
    on_add_remote_stream?.call(stream);
    remote_stream = stream;
  };
}
