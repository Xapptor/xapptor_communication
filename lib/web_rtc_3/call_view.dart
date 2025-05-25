import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/create_anwser.dart';
import 'package:xapptor_communication/web_rtc_3/create_offer.dart';

class CallView extends StatefulWidget {
  final String user_id;

  const CallView({
    super.key,
    required this.user_id,
  });

  @override
  State<CallView> createState() => CallViewState();
}

class CallViewState extends State<CallView> {
  final TextEditingController call_input = TextEditingController();

  final String sdp_semantics = 'unified-plan';

  final Map<String, dynamic> ice_servers = {
    "iceServers": [
      {
        "urls": [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
    "iceCandidatePoolSize": 10,
  };

  final Map<String, dynamic> config = {
    'mandatory': {},
    'optional': [
      {
        'DtlsSrtpKeyAgreement': true,
      },
    ]
  };

  final RTCVideoRenderer local_video_renderer = RTCVideoRenderer();
  final RTCVideoRenderer remote_video_renderer = RTCVideoRenderer();

  late RTCPeerConnection peer_connection;
  MediaStream? local_stream;
  final List<RTCIceCandidate> candidate_buffer = []; // Buffer for ICE candidates

  @override
  void initState() {
    super.initState();
    _initialize_renderers();
  }

  Future<void> _initialize_renderers() async {
    await local_video_renderer.initialize();
    await remote_video_renderer.initialize();
  }

  @override
  void dispose() {
    local_video_renderer.dispose();
    remote_video_renderer.dispose();
    call_input.dispose();
    peer_connection.close();
    local_stream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter WebRTC Demo")),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(local_video_renderer, mirror: true)),
                Expanded(child: RTCVideoView(remote_video_renderer)),
              ],
            ),
          ),
          TextField(
            controller: call_input,
            decoration: const InputDecoration(labelText: 'Enter Call ID'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: create_offer,
                child: const Text("Create Call"),
              ),
              ElevatedButton(
                onPressed: create_answer,
                child: const Text("Answer Call"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
