import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/create_stream.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/data_channel.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<Session> create_session(
    Session? session, {
    required String peer_id,
    required String session_id,
    required String media,
    required bool screen_sharing,
  }) async {
    Session new_session = session ??
        Session(
          id: session_id,
          peer_id: peer_id,
        );

    if (media != 'data') {
      local_stream = await create_stream(
        media,
        screen_sharing,
        context: context,
      );
    }

    debugPrint(ice_servers.toString());
    RTCPeerConnection pc = await createPeerConnection({
      ...ice_servers,
      ...{'sdpSemantics': sdp_semantics}
    }, config);
    if (media != 'data') {
      switch (sdp_semantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            on_add_remote_stream?.call(new_session, stream);
            remote_streams.add(stream);
          };
          await pc.addStream(local_stream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          pc.onTrack = (event) {
            if (event.track.kind == 'video') {
              on_add_remote_stream?.call(new_session, event.streams[0]);
            }
          };
          local_stream!.getTracks().forEach((track) async {
            senders.add(await pc.addTrack(track, local_stream!));
          });
          break;
      }

      // Unified-Plan: Simuclast
      /*
      await pc.addTransceiver(
        track: _localStream.getAudioTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly, streams: [_localStream]),
      );

      await pc.addTransceiver(
        track: _localStream.getVideoTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            streams: [
              _localStream
            ],
            sendEncodings: [
              RTCRtpEncoding(rid: 'f', active: true),
              RTCRtpEncoding(
                rid: 'h',
                active: true,
                scaleResolutionDownBy: 2.0,
                maxBitrate: 150000,
              ),
              RTCRtpEncoding(
                rid: 'q',
                active: true,
                scaleResolutionDownBy: 4.0,
                maxBitrate: 100000,
              ),
            ]),
      );*/
      /*
        var sender = pc.getSenders().find(s => s.track.kind == "video");
        var parameters = sender.getParameters();
        if(!parameters)
          parameters = {};
        parameters.encodings = [
          { rid: "h", active: true, maxBitrate: 900000 },
          { rid: "m", active: true, maxBitrate: 300000, scaleResolutionDownBy: 2 },
          { rid: "l", active: true, maxBitrate: 100000, scaleResolutionDownBy: 4 }
        ];
        sender.setParameters(parameters);
      */
    }
    pc.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate == null) {
        debugPrint('onIceCandidate: complete!');
        return;
      }
      // This delay is needed to allow enough time to try an ICE candidate
      // before skipping to the next one. 1 second is just an heuristic value
      // and should be thoroughly tested in your own environment.

      // MARK: Code Migrated from on_message function
      if (session != null) {
        if (session.peer_connection != null) {
          await session.peer_connection?.addCandidate(candidate);
        } else {
          session.remote_candidates.add(candidate);
        }
      } else {
        sessions[session_id] = Session(
          peer_id: peer_id,
          id: session_id,
        )..remote_candidates.add(candidate);
      }
      // MARK: Code Migrated from on_message function
    };

    pc.onIceConnectionState = (state) {};

    pc.onRemoveStream = (stream) {
      on_remove_remote_stream?.call(new_session, stream);
      remote_streams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      add_data_channel(new_session, channel);
    };

    new_session.peer_connection = pc;
    return new_session;
  }
}
