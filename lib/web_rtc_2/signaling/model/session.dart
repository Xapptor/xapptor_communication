import 'package:flutter_webrtc/flutter_webrtc.dart';

class Session {
  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remote_candidates = [];

  Session({
    required this.sid,
    required this.pid,
  });
}
