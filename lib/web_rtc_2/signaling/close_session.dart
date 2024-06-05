import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future close_session(Session session) async {
    local_stream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await local_stream?.dispose();
    local_stream = null;

    await session.peer_connection?.close();
    await session.data_channel?.close();
    senders.clear();
    video_source = VideoSource.camera;
  }

  close_session_by_peer_id(String peer_id) {
    Session? session;
    sessions.removeWhere((String key, Session current_session) {
      var ids = key.split('-');
      session = current_session;
      return peer_id == ids[0] || peer_id == ids[1];
    });
    if (session != null) {
      close_session(session!);
      on_call_state_change?.call(session!, CallState.cl_bye);
    }
  }
}
