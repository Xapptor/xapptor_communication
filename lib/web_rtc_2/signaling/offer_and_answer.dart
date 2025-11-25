import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/call_line/update_call_line.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/create_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  // MARK: Create Offer
  Future<void> create_offer({
    required Session session,
    required String media,
    required String contact_id,
  }) async {
    try {
      RTCSessionDescription session_description = await session.peer_connection!.createOffer(
        media == 'data' ? session_description_constraints : {},
      );

      await session.peer_connection!.setLocalDescription(fix_sdp(session_description));

      // MARK: Code Migrated from on_message function
      Session new_session = await create_session(
        session,
        peer_id: session.peer_id,
        session_id: session.id,
        media: media,
        screen_sharing: false,
      );

      sessions[session.id] = new_session;

      await new_session.peer_connection?.setRemoteDescription(
        RTCSessionDescription(
          session_description.sdp,
          session_description.type,
        ),
      );
      // await _createAnswer(newSession, media);

      if (new_session.remote_candidates.isNotEmpty) {
        for (var candidate in new_session.remote_candidates) {
          await new_session.peer_connection?.addCandidate(candidate);
        }
        new_session.remote_candidates.clear();
      }
      on_call_state_change?.call(new_session, CallState.cl_new, null);
      // TODO: This was commented on_call_state_change?.call(new_session, CallState.cl_ringing);
      // MARK: Code Migrated from on_message function

      Room room = await create_room(
        user_id: user_id,
      );

      await update_call_line(
        caller_id: user_id,
        room_id: room.id,
        session_id: session.id,
        contact_id: contact_id,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // MARK: Fix SDP
  RTCSessionDescription fix_sdp(RTCSessionDescription session_description) {
    var sdp = session_description.sdp;
    session_description.sdp = sdp!.replaceAll(
      'profile-level-id=640c1f',
      'profile-level-id=42e032',
    );
    return session_description;
  }

  // MARK: Create Answer
  Future<void> create_answer({
    required Session session,
    required String media,
  }) async {
    try {
      RTCSessionDescription session_description = await session.peer_connection!.createAnswer(
        media == 'data' ? session_description_constraints : {},
      );

      await session.peer_connection!.setLocalDescription(fix_sdp(session_description));

      // MARK: Code Migrated from on_message function
      session.peer_connection?.setRemoteDescription(
        RTCSessionDescription(
          session_description.sdp,
          session_description.type,
        ),
      );
      on_call_state_change?.call(session, CallState.cl_connected, null);
      // MARK: Code Migrated from on_message function
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
