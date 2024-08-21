import 'package:flutter_webrtc/flutter_webrtc.dart';

class Session {
  String id;
  String peer_id;
  RTCPeerConnection? peer_connection;
  RTCDataChannel? data_channel;
  List<RTCIceCandidate> remote_candidates = [];

  Session({
    required this.id,
    required this.peer_id,
  });

  Session.from_snapshot(
    this.id,
    Map<dynamic, dynamic> snapshot,
  )   : peer_id = snapshot['peer_id'] ?? '',
        peer_connection = snapshot['peer_connection'] ?? '',
        data_channel = snapshot['sessidata_channelon_id'] ?? '',
        remote_candidates = snapshot['remote_candidates'] ?? '';

  Map<String, dynamic> to_json() {
    return {
      'id': id,
      'peer_id': peer_id,
      'remote_candidates': remote_candidates,
    };
  }
}
