import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/close_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/create_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  on_message(message) async {
    Map<String, dynamic> map_data = message;
    var data = map_data['data'];

    switch (map_data['type']) {
      case 'peers':
        {
          List<dynamic> peers = data;
          if (on_peers_update != null) {
            Map<String, dynamic> event = <String, dynamic>{};
            event['self'] = self_id;
            event['peers'] = peers;
            on_peers_update?.call(event);
          }
        }
        break;
      case 'offer':
        {
          var peer_id = data['from'];
          var description = data['description'];
          var media = data['media'];
          var session_id = data['session_id'];
          var session = sessions[session_id];
          var new_session = await create_session(
            session,
            peer_id: peer_id,
            session_id: session_id,
            media: media,
            screen_sharing: false,
          );

          sessions[session_id] = new_session;

          await new_session.pc?.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
          // await _createAnswer(newSession, media);

          if (new_session.remote_candidates.isNotEmpty) {
            for (var candidate in new_session.remote_candidates) {
              await new_session.pc?.addCandidate(candidate);
            }
            new_session.remote_candidates.clear();
          }
          on_call_state_change?.call(new_session, CallState.cl_new);
          on_call_state_change?.call(new_session, CallState.cl_ringing);
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = sessions[sessionId];
          session?.pc?.setRemoteDescription(RTCSessionDescription(description['sdp'], description['type']));
          on_call_state_change?.call(session!, CallState.cl_connected);
        }
        break;
      case 'candidate':
        {
          var peer_id = data['from'];
          var candidate_map = data['candidate'];
          var session_id = data['session_id'];
          var session = sessions[session_id];

          RTCIceCandidate candidate = RTCIceCandidate(
            candidate_map['candidate'],
            candidate_map['sdpMid'],
            candidate_map['sdpMLineIndex'],
          );

          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remote_candidates.add(candidate);
            }
          } else {
            sessions[session_id] = Session(pid: peer_id, sid: session_id)..remote_candidates.add(candidate);
          }
        }
        break;
      case 'leave':
        {
          var peer_id = data as String;
          close_session_by_peer_id(peer_id);
        }
        break;
      case 'bye':
        {
          var session_id = data['session_id'];
          debugPrint('bye: $session_id');
          var session = sessions.remove(session_id);
          if (session != null) {
            on_call_state_change?.call(session, CallState.cl_bye);
            close_session(session);
          }
        }
        break;
      case 'keepalive':
        {
          debugPrint('keepalive response!');
        }
        break;
      default:
        break;
    }
  }
}
