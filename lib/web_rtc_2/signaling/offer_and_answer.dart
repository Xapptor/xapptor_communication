import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<void> create_offer(
    Session session,
    String media,
  ) async {
    try {
      RTCSessionDescription session_description = await session.pc!.createOffer(media == 'data' ? dc_constraints : {});

      await session.pc!.setLocalDescription(fix_sdp(session_description));
      send(
        'offer',
        {
          'to': session.pid,
          'from': self_id,
          'description': {
            'sdp': session_description.sdp,
            'type': session_description.type,
          },
          'session_id': session.sid,
          'media': media,
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  RTCSessionDescription fix_sdp(RTCSessionDescription session_description) {
    var sdp = session_description.sdp;
    session_description.sdp = sdp!.replaceAll(
      'profile-level-id=640c1f',
      'profile-level-id=42e032',
    );
    return session_description;
  }

  Future<void> create_answer(
    Session session,
    String media,
  ) async {
    try {
      RTCSessionDescription session_description = await session.pc!.createAnswer(media == 'data' ? dc_constraints : {});
      await session.pc!.setLocalDescription(fix_sdp(session_description));
      send(
        'answer',
        {
          'to': session.pid,
          'from': self_id,
          'description': {
            'sdp': session_description.sdp,
            'type': session_description.type,
          },
          'session_id': session.sid,
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
