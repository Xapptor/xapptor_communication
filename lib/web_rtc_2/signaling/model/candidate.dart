import 'package:flutter_webrtc/flutter_webrtc.dart';

RTCIceCandidate candidate_from_snapshot(
  Map<dynamic, dynamic> snapshot,
) =>
    RTCIceCandidate(
      snapshot['candidate'],
      snapshot['sdpMid'],
      snapshot['sdpMLineIndex'],
    );

Map<String, dynamic> candidate_to_json(RTCIceCandidate candidate) {
  return {
    'candidate': candidate.candidate,
    'sdpMid': candidate.sdpMid,
    'sdpMLineIndex': candidate.sdpMLineIndex,
  };
}
