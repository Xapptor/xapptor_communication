// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/call_view.dart';
import 'package:xapptor_db/xapptor_db.dart';

extension CallViewStateExtension on CallViewState {
  // initialize_peer_connection() async {
  //   print("_start_webcam_");

  //   await local_video_renderer.initialize();
  //   await remote_video_renderer.initialize();

  //   peer_connection = await createPeerConnection(
  //     {
  //       ...ice_servers,
  //       ...{
  //         'sdpSemantics': sdp_semantics,
  //       }
  //     },
  //     config,
  //   );

  //   local_stream = await navigator.mediaDevices.getUserMedia({
  //     "video": true,
  //     "audio": true,
  //   });

  //   // remote_stream = MediaStream();
  //   remote_stream = await createLocalMediaStream('remote_stream');

  //   local_stream?.getTracks().forEach((track) async {
  //     await peer_connection.addTrack(track, local_stream);
  //   });

  //   local_video_renderer.srcObject = local_stream;
  //   remote_video_renderer.srcObject = remote_stream;

  //   peer_connection.onTrack = (event) {
  //     print("_onTrack_");
  //     remote_stream = event.streams[0];

  //     setState(() => {});

  //     event.streams[0].getTracks().forEach((track) {
  //       remote_stream.addTrack(track);
  //       remote_video_renderer.srcObject?.addTrack(track);
  //     });

  //     setState(() => {});
  //   };

  //   setState(() => {});
  // }

  Future<void> initialize_peer_connection() async {
    peer_connection = await createPeerConnection({
      ...ice_servers,
    });

    peer_connection.onIceCandidate = (RTCIceCandidate candidate) {
      print("New ICE candidate generated: ${candidate.toMap()}");

      XapptorDB.instance
          .collection('calls')
          .doc(call_input.text)
          .collection('answer_candidates')
          .add(candidate.toMap());
    };

    peer_connection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        print("Received remote stream: ${event.streams[0]}");
        setState(() {
          remote_video_renderer.srcObject = event.streams[0];
        });
      }
    };

    local_stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    local_stream?.getTracks().forEach((track) {
      peer_connection.addTrack(track, local_stream!);
    });

    setState(() {
      local_video_renderer.srcObject = local_stream;
    });
  }
}
