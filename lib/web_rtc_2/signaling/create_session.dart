import 'package:xapptor_db/xapptor_db.dart';
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

    RTCPeerConnection peer_connection = await createPeerConnection({
      ...ice_servers,
      ...{'sdpSemantics': sdp_semantics}
    }, config);
    if (media != 'data') {
      switch (sdp_semantics) {
        case 'plan-b':
          peer_connection.onAddStream = (MediaStream stream) {
            on_add_remote_stream?.call(new_session, stream);
            remote_streams.add(stream);
          };
          await peer_connection.addStream(local_stream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          peer_connection.onTrack = (event) {
            if (event.track.kind == 'video') {
              on_add_remote_stream?.call(new_session, event.streams[0]);
            }
          };
          local_stream!.getTracks().forEach((track) async {
            senders.add(await peer_connection.addTrack(track, local_stream!));
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
    peer_connection.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate == null) {
        debugPrint('onIceCandidate: complete!');
        return;
      }
      // This delay is needed to allow enough time to try an ICE candidate
      // before skipping to the next one. 1 second is just an heuristic value
      // and should be thoroughly tested in your own environment.

      // MARK: Code Migrated from on_message function

      if (new_session.peer_connection != null) {
        await new_session.peer_connection?.addCandidate(candidate);
      } else {
        new_session.remote_candidates.add(candidate);
      }

      // MARK: Code Migrated from on_message function
    };

    peer_connection.onIceConnectionState = (state) {};

    peer_connection.onRemoveStream = (stream) {
      on_remove_remote_stream?.call(new_session, stream);
      remote_streams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    peer_connection.onDataChannel = (channel) {
      add_data_channel(new_session, channel);
    };

    new_session.peer_connection = peer_connection;

    await _create_session_on_db(new_session);

    return new_session;
  }

  Future _create_session_on_db(Session session) async {
    Map<String, dynamic> session_json = session.to_json();

    print(session_json);

    await XapptorDB.instance.collection('sessions').doc(session.id).set(session_json);
  }
}
