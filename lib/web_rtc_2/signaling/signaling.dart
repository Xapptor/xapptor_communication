import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/clean_sessions.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/close_session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/offer_and_answer.dart';

class Signaling {
  final BuildContext? context;
  final String user_id;

  Signaling({
    required this.context,
    required this.user_id,
  });

  final JsonEncoder encoder = const JsonEncoder();
  final JsonDecoder decoder = const JsonDecoder();

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
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }
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

  final Map<String, dynamic> session_description_constraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  bool is_mute = false;

  close() async {
    await clean_essions();
  }

  void bye(String session_id) {
    // MARK: Code Migrated from on_message function
    debugPrint('bye: $session_id');
    var session = sessions.remove(session_id);
    if (session != null) {
      on_call_state_change?.call(session, CallState.cl_bye);
      close_session(session);
    }
    // MARK: Code Migrated from on_message function
  }

  void accept(String session_id, String media) {
    var session = sessions[session_id];
    if (session == null) {
      return;
    }
    create_answer(
      session: session,
      media: media,
    );
  }

  void reject(String session_id) {
    var session = sessions[session_id];
    if (session == null) {
      return;
    }
    bye(session.id);
  }
}
