import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future update_call_line({
    required String caller_id,
    required String room_id,
    required String session_id,
    required String contact_id,
  }) async {
    DocumentReference call_line = FirebaseFirestore.instance.collection('call_lines').doc(contact_id);

    await call_line.set(
      {
        'caller_id': caller_id,
        'room_id': room_id,
        'session_id': session_id,
      },
      SetOptions(merge: true),
    );
  }
}
