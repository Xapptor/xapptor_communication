import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/create_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<void> create_offer(
    Session session,
    String media,
  ) async {
    try {
      RTCSessionDescription session_description = await session.peer_connection!.createOffer(
        media == 'data' ? session_description_constraints : {},
      );

      await session.peer_connection!.setLocalDescription(fix_sdp(session_description));

      // MARK: Code Migrated from on_message function
      var new_session = await create_session(
        session,
        peer_id: session.peer_id,
        session_id: session.id,
        media: media,
        screen_sharing: false,
      );

      sessions[session.id] = new_session;

      await new_session.peer_connection?.setRemoteDescription(
        RTCSessionDescription(session_description.sdp, session_description.type),
      );
      // await _createAnswer(newSession, media);

      if (new_session.remote_candidates.isNotEmpty) {
        for (var candidate in new_session.remote_candidates) {
          await new_session.peer_connection?.addCandidate(candidate);
        }
        new_session.remote_candidates.clear();
      }
      on_call_state_change?.call(new_session, CallState.cl_new);
      on_call_state_change?.call(new_session, CallState.cl_ringing);
      // MARK: Code Migrated from on_message function
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
      RTCSessionDescription session_description =
          await session.peer_connection!.createAnswer(media == 'data' ? session_description_constraints : {});
      await session.peer_connection!.setLocalDescription(fix_sdp(session_description));

      // MARK: Code Migrated from on_message function
      session.peer_connection?.setRemoteDescription(RTCSessionDescription(
        session_description.sdp,
        session_description.type,
      ));
      on_call_state_change?.call(session, CallState.cl_connected);
      // MARK: Code Migrated from on_message function
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
