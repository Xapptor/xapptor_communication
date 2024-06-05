import 'package:flutter_webrtc/flutter_webrtc.dart';

class Session {
  String peer_id;
  String id;
  RTCPeerConnection? peer_connection;
  RTCDataChannel? data_channel;
  List<RTCIceCandidate> remote_candidates = [];

  Session({
    required this.id,
    required this.peer_id,
  });
}
