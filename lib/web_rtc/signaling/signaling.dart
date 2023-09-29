import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'model/peer_connection.dart';

typedef StreamStateCallback = Function(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }
    ]
  };
  FirebaseFirestore db = FirebaseFirestore.instance;
  late CollectionReference rooms_ref;

  String? current_room_text;
  late String user_id;
  ValueNotifier<String?> room_id = ValueNotifier<String?>(null);
  MediaStream? local_stream;
  List<MediaStream> remote_streams = [];
  List<PeerConnection> peer_connections = [];
  StreamStateCallback? on_add_remote_stream;

  init({
    required String user_id,
  }) {
    this.user_id = user_id;
    rooms_ref = db.collection('rooms');
  }
}
