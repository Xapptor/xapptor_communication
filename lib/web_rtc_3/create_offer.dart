import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/call_view.dart';
import 'package:xapptor_communication/web_rtc_3/start_webcam.dart';

extension CallViewStateExtension on CallViewState {
  // create_offer() async {
  //   print("_create_offer_");

  //   DocumentReference call_doc = XapptorDB.instance.collection('calls').doc();
  //   CollectionReference offer_candidates_collection = call_doc.collection('offer_candidates');
  //   CollectionReference answer_candidates_collection = call_doc.collection('answer_candidates');

  //   call_input.text = call_doc.id;

  //   peer_connection.onIceCandidate = (new_ice_candidate) {
  //     if (new_ice_candidate.candidate != null) {
  //       offer_candidates_collection.add(new_ice_candidate.toMap());
  //     }
  //   };

  //   RTCSessionDescription offer_description = await peer_connection.createOffer();

  //   await peer_connection.setLocalDescription(offer_description);

  //   Map<String, dynamic> offer = {
  //     'sdp': offer_description.sdp,
  //     'type': offer_description.type,
  //   };

  //   await call_doc.set({'offer': offer});

  //   call_doc.snapshots().listen((snapshot) async {
  //     Map<String, dynamic> call_data = snapshot.data() as Map<String, dynamic>;

  //     if (await peer_connection.getRemoteDescription() == null && call_data['answer'] != null) {
  //       RTCSessionDescription answer_description = RTCSessionDescription(
  //         call_data['answer']['sdp'],
  //         call_data['answer']['type'],
  //       );
  //       peer_connection.setRemoteDescription(answer_description);
  //     }
  //   });

  //   answer_candidates_collection.snapshots().listen((snapshot) {
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

  //   // hangupButton.disabled = false;
  // }

  Future<void> create_offer() async {
    await initialize_peer_connection();

    // Create the offer and set it as the local description
    final offer = await peer_connection.createOffer();
    await peer_connection.setLocalDescription(offer);

    // Generate a new call document in Firestore
    final callDoc = FirebaseFirestore.instance.collection('calls').doc();
    call_input.text = callDoc.id;

    // Set the offer in Firestore
    await callDoc.set({
      'offer': offer.toMap(),
    });

    // Buffer to store incoming ICE candidates until remote description is set
    List<RTCIceCandidate> candidateBuffer = [];

    // Listen for answer candidates from Firestore and add them when ready
    callDoc.collection('answer_candidates').snapshots().listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          final candidate = RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          );

          // If remote description is set, add the candidate immediately; otherwise, buffer it
          if (await peer_connection.getRemoteDescription() != null) {
            peer_connection.addCandidate(candidate);
          } else {
            print("Buffering ICE candidate until remote description is set");
            candidateBuffer.add(candidate);
          }
        }
      }
    });

    // Listen for changes to the call document to detect when the answer is available
    callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null && data['answer'] != null) {
        // Set the remote description with the answer
        final answer = data['answer'];
        await peer_connection.setRemoteDescription(RTCSessionDescription(
          answer['sdp'],
          answer['type'],
        ));

        // Once the remote description is set, add any buffered ICE candidates
        for (var candidate in candidateBuffer) {
          await peer_connection.addCandidate(candidate);
        }
        candidateBuffer.clear(); // Clear the buffer after adding candidates
      }
    });
  }
}
