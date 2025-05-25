import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/call_line.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_db/xapptor_db.dart';

extension SignalingExtension on Signaling {
  subscribe_to_call_line({
    required String user_id,
  }) async {
    DocumentReference call_line_ref = XapptorDB.instance.collection('call_lines').doc(user_id);
    call_line_ref.snapshots().listen((event) async {
      if (event.data() != null) {
        CallLine call_line = CallLine.from_snapshot(user_id, event.data() as Map<String, dynamic>);
        if (call_line.caller_id != '' && call_line.room_id != '') {
          DocumentSnapshot session_snap =
              await XapptorDB.instance.collection('sessions').doc(call_line.session_id).get();

          Session session = Session.from_snapshot(
            call_line.session_id,
            session_snap.data() as Map<String, dynamic>,
          );

          on_call_state_change?.call(session, CallState.cl_ringing, null);
        }
      }
    });
  }
}
