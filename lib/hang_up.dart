import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future hang_up({
  required RTCVideoRenderer local_video,
  required MediaStream? local_stream,
  required MediaStream? remote_stream,
  required RTCPeerConnection? peer_connection,
  required String? room_id,
}) async {
  List<MediaStreamTrack> tracks = local_video.srcObject!.getTracks();
  tracks.forEach((track) {
    track.stop();
  });

  if (remote_stream != null) {
    remote_stream.getTracks().forEach((track) => track.stop());
  }
  if (peer_connection != null) peer_connection.close();

  if (room_id != null) {
    var db = FirebaseFirestore.instance;
    var room_ref = db.collection('rooms').doc(room_id);
    var callee_candidates = await room_ref.collection('calleeCandidates').get();
    callee_candidates.docs.forEach((document) => document.reference.delete());

    var caller_candidates = await room_ref.collection('callerCandidates').get();
    caller_candidates.docs.forEach((document) => document.reference.delete());

    await room_ref.delete();
  }

  local_stream!.dispose();
  remote_stream?.dispose();
}
