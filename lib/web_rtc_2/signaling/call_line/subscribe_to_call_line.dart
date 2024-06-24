import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/call_line.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  subscribe_to_call_line({
    required String user_id,
  }) {
    DocumentReference call_line = FirebaseFirestore.instance.collection('call_lines').doc(user_id);
    call_line.snapshots().listen((event) {
      print('Call Line: ${event.data()}');
      CallLine call_line = CallLine.from_snapshot(user_id, event.data() as Map<String, dynamic>);
      if (call_line.caller_id != '' && call_line.room_id != '') {
        Session session = Session(
          id: '',
          peer_id: '',
        );

        on_call_state_change?.call(session, CallState.cl_ringing);
      }
    });
  }
}
