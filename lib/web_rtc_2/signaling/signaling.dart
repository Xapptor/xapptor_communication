import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/clean_sessions.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/close_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/offer_and_answer.dart';
import 'package:xapptor_communication/web_rtc_2/utils/websocket.dart'
    if (dart.library.js) 'package:xapptor_communication/web_rtc_2/utils/websocket_web.dart';

class Signaling {
  Signaling(
    this.host,
    this.context,
  );

  final JsonEncoder encoder = const JsonEncoder();
  final JsonDecoder decoder = const JsonDecoder();
  final String self_id = "awrgq35harfhdf"; // TODO: generate random id
  SimpleWebSocket? socket;
  final BuildContext? context;
  final String host;
  final port = 8086;
  Map? turn_credential;
  final Map<String, Session> sessions = {};
  MediaStream? local_stream;
  final List<MediaStream> remote_streams = <MediaStream>[];
  final List<RTCRtpSender> senders = <RTCRtpSender>[];
  VideoSource video_source = VideoSource.camera;

  Function(SignalingState state)? on_signaling_state_change;
  Function(Session session, CallState state)? on_call_state_change;
  Function(MediaStream stream)? on_local_stream;
  Function(Session session, MediaStream stream)? on_add_remote_stream;
  Function(Session session, MediaStream stream)? on_remove_remote_stream;
  Function(dynamic event)? on_peers_update;
  Function(Session session, RTCDataChannel data_channel, RTCDataChannelMessage data)? on_data_channel_message;
  Function(Session session, RTCDataChannel data_channel)? on_data_channel;

  String get sdp_semantics => 'unified-plan';

  Map<String, dynamic> ice_servers = {
    'iceServers': [
      {
        'url': 'stun:stun.l.google.com:19302',
      },
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
      */
    ]
  };

  final Map<String, dynamic> config = {
    'mandatory': {},
    'optional': [
      {
        'DtlsSrtpKeyAgreement': true,
      },
    ]
  };

  final Map<String, dynamic> dc_constraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  close() async {
    await clean_essions();
    socket?.close();
  }

  void bye(String sessionId) {
    send(
      'bye',
      {
        'session_id': sessionId,
        'from': self_id,
      },
    );
    var session = sessions[sessionId];
    if (session != null) {
      close_session(session);
    }
  }

  void accept(String session_id, String media) {
    var session = sessions[session_id];
    if (session == null) {
      return;
    }
    create_answer(session, media);
  }

  void reject(String session_id) {
    var session = sessions[session_id];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  send(event, data) {
    var request = {};
    request["type"] = event;
    request["data"] = data;
    socket?.send(encoder.convert(request));
  }
}
