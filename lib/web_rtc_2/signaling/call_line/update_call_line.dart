import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/call_line.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<CallLine> update_call_line({
    required String caller_id,
    required String room_id,
    required String session_id,
    required String contact_id,
  }) async {
    CallLine call_line = CallLine(
      id: contact_id,
      caller_id: caller_id,
      room_id: room_id,
      session_id: session_id,
    );

    await FirebaseFirestore.instance.collection('call_lines').doc(contact_id).set(
          call_line.to_json(),
          SetOptions(merge: true),
        );
    return call_line;
  }
}
