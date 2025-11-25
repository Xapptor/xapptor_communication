import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/call_view.dart';
import 'package:xapptor_communication/web_rtc_3/start_webcam.dart';
import 'package:xapptor_db/xapptor_db.dart';

extension CallViewStateExtension on CallViewState {
  // create_answer() async {
  //   print("_create_answer_");

  //   String call_id = call_input.text;
  //   DocumentReference call_doc = XapptorDB.instance.collection('calls').doc(call_id);
  //   CollectionReference answer_candidates_collection = call_doc.collection('answer_candidates');
  //   CollectionReference offer_candidates_collection = call_doc.collection('offer_candidates');

  //   peer_connection.onIceCandidate = (new_ice_candidate) {
  //     if (new_ice_candidate.candidate != null) {
  //       answer_candidates_collection.add(new_ice_candidate.toMap());
  //     }
  //   };

  //   Map<String, dynamic> call_data = (await call_doc.get()).data() as Map<String, dynamic>;

  //   RTCSessionDescription offer_description = RTCSessionDescription(
  //     call_data['offer']['sdp'],
  //     call_data['offer']['type'],
  //   );

  //   await peer_connection.setRemoteDescription(offer_description);

  //   RTCSessionDescription answer_description = await peer_connection.createAnswer();
  //   await peer_connection.setLocalDescription(answer_description);

  //   Map<String, dynamic> answer = {
  //     'type': answer_description.type,
  //     'sdp': answer_description.sdp,
  //   };

  //   await call_doc.update({'answer': answer});

  //   offer_candidates_collection.snapshots().listen((snapshot) {
  //     for (var change in snapshot.docChanges) {
  //       if (change.type == DocumentChangeType.added) {
  //         Map<String, dynamic> candidate_map = change.doc.data() as Map<String, dynamic>;

  //         RTCIceCandidate new_anwser_candidate = RTCIceCandidate(
  //           candidate_map['candidate'],
  //           candidate_map['sdpMid'],
  //           candidate_map['sdpMLineIndex'],
  //         );
  //         peer_connection.addCandidate(new_anwser_candidate);
  //       }
  //     }
  //   });
  // }

  Future<void> create_answer() async {
    await initialize_peer_connection();

    final callId = call_id_controller.text;
    final callDoc = XapptorDB.instance.collection('calls').doc(callId);
    final callData = (await callDoc.get()).data();

    if (callData == null || callData['offer'] == null) {
      return;
    }

    // Set remote description with the offer data
    final offer = callData['offer'];
    await peer_connection.setRemoteDescription(RTCSessionDescription(
      offer['sdp'],
      offer['type'],
    ));

    // Create and set the local answer description
    final answer = await peer_connection.createAnswer();
    await peer_connection.setLocalDescription(answer);
    callDoc.update({
      'answer': answer.toMap(),
    });

    // Add ICE candidates received before remote description was set
    for (var candidate in candidate_buffer) {
      await peer_connection.addCandidate(candidate);
    }
    candidate_buffer.clear();

    // Listen for offer side candidates
    callDoc.collection('offer_candidates').snapshots().listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          final candidate = RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          );

          // Buffer candidates if remote description not set
          if (await peer_connection.getRemoteDescription() == null) {
            candidate_buffer.add(candidate);
          } else {
            peer_connection.addCandidate(candidate);
          }
        }
      }
    });
  }
}
