import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/candidate.dart';

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
        peer_connection = null,
        // TODO: Resolve this
        // peer_connection = snapshot['peer_connection'] ?? '',
        // data_channel = snapshot['data_channel'] ?? '',
        remote_candidates = snapshot['remote_candidates'] != null
            ? (snapshot['remote_candidates'] as List<dynamic>).map((e) => candidate_from_snapshot(e)).toList()
            : [];

  Map<String, dynamic> to_json() {
    return {
      'peer_id': peer_id,
      // TODO: Resolve this
      // 'peer_connection': peer_connection,
      // 'data_channel': data_channel,
      'remote_candidates': remote_candidates.map((e) => candidate_to_json(e)).toList(),
    };
  }
}
