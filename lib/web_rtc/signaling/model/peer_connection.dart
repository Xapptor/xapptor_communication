import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnection {
  final String id;
  final RTCPeerConnection value;

  const PeerConnection({
    required this.id,
    required this.value,
  });
}
