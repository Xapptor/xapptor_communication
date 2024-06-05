import 'package:xapptor_communication/web_rtc_2/signaling/create_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/data_channel.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/offer_and_answer.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  void invite(
    String peer_id,
    String media,
    bool use_screen,
  ) async {
    var session_id = '$self_id-$peer_id';

    Session session = await create_session(
      null,
      peer_id: peer_id,
      session_id: session_id,
      media: media,
      screen_sharing: use_screen,
    );

    sessions[session_id] = session;
    if (media == 'data') {
      create_data_channel(session);
    }
    create_offer(session, media);
    on_call_state_change?.call(session, CallState.cl_new);
    on_call_state_change?.call(session, CallState.cl_invite);
  }
}
