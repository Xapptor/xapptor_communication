import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };
  FirebaseFirestore db = FirebaseFirestore.instance;
  late CollectionReference rooms_ref;
  late CollectionReference connections_ref;

  String? current_room_text;
  late String user_id;
  String? room_id;
  MediaStream? local_stream;
  MediaStream? remote_stream;
  RTCPeerConnection? peer_connection;
  StreamStateCallback? on_add_remote_stream;

  init({
    required String user_id,
  }) {
    this.user_id = user_id;
    rooms_ref = db.collection('rooms');
    connections_ref = db.collection('connections');
  }
}
