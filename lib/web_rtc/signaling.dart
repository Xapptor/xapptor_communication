import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';

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

  RTCPeerConnection? peer_connection;
  MediaStream? local_stream;
  MediaStream? remote_stream;
  String? room_id;
  String? current_room_text;
  StreamStateCallback? on_add_remote_stream;

  // Create room and return ID

  Future<String> create_room(RTCVideoRenderer remote_renderer) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference room_ref = db.collection('rooms').doc();

    print('Create PeerConnection with configuration: $configuration');

    peer_connection = await createPeerConnection(configuration);

    register_peer_connection_listeners();

    local_stream?.getTracks().forEach((track) {
      peer_connection?.addTrack(track, local_stream!);
    });

    // Code for collecting ICE candidates below
    var caller_candidates_collection = room_ref.collection('callerCandidates');

    peer_connection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      caller_candidates_collection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peer_connection!.createOffer();
    await peer_connection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> room_with_offer = {'offer': offer.toMap()};

    await room_ref.set(room_with_offer);
    var room_id = room_ref.id;
    print('New room created with SDK offer. Room ID: $room_id');
    current_room_text = 'Current room is $room_id - You are the caller!';
    // Created a Room

    peer_connection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remote_stream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    room_ref.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peer_connection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await peer_connection?.setRemoteDescription(answer);
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    room_ref.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peer_connection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
    // Listen for remote ICE candidates above
    return room_id;
  }

  // Join room call

  Future<void> join_room(String room_id, RTCVideoRenderer remote_video) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference room_ref = db.collection('rooms').doc('$room_id');
    var room_snapshot = await room_ref.get();
    print('Got room ${room_snapshot.exists}');

    if (room_snapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      peer_connection = await createPeerConnection(configuration);

      register_peer_connection_listeners();

      local_stream?.getTracks().forEach((track) {
        peer_connection?.addTrack(track, local_stream!);
      });

      // Code for collecting ICE candidates below
      var callee_candidates_collection =
          room_ref.collection('calleeCandidates');
      peer_connection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        callee_candidates_collection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peer_connection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remote_stream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = room_snapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await peer_connection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peer_connection!.createAnswer();
      print('Created Answer $answer');

      await peer_connection!.setLocalDescription(answer);

      Map<String, dynamic> room_with_answer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await room_ref.update(room_with_answer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      room_ref.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          peer_connection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  // Open camera and microphone

  Future<void> open_user_media({
    required RTCVideoRenderer local_renderer,
    required RTCVideoRenderer remote_renderer,
    required String audio_device_id,
    required String video_device_id,
    required bool enable_audio,
    required bool enable_video,
  }) async {
    if (enable_audio || enable_video) {
      String facing_mode = '';
      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
        facing_mode = video_device_id == "0" ? 'environment' : 'user';
      }

      Map video_json = {
        'deviceId': video_device_id,
      };

      if (facing_mode != '') {
        video_json['facingMode'] = facing_mode;
      }

      var stream = await navigator.mediaDevices.getUserMedia(
        {
          'audio': enable_audio
              ? {
                  'deviceId': audio_device_id,
                }
              : false,
          'video': enable_video ? video_json : false,
        },
      );

      local_renderer.srcObject = stream;
      local_stream = stream;
      remote_renderer.srcObject = await createLocalMediaStream('key');
      local_renderer.muted = !enable_audio;
    }
  }

  // Hang Up Call

  Future<void> hang_up(RTCVideoRenderer local_video) async {
    List<MediaStreamTrack> tracks = local_video.srcObject!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });

    if (remote_stream != null) {
      remote_stream!.getTracks().forEach((track) => track.stop());
    }
    if (peer_connection != null) peer_connection!.close();

    if (room_id != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(room_id);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      calleeCandidates.docs.forEach((document) => document.reference.delete());

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      callerCandidates.docs.forEach((document) => document.reference.delete());

      await roomRef.delete();
    }

    local_stream!.dispose();
    remote_stream?.dispose();
  }

  // Registering peer connection listeners

  void register_peer_connection_listeners() {
    peer_connection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peer_connection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peer_connection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peer_connection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peer_connection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      on_add_remote_stream?.call(stream);
      remote_stream = stream;
    };
  }
}
