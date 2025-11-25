import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc_3/create_anwser.dart';
import 'package:xapptor_communication/web_rtc_3/create_offer.dart';
import 'package:xapptor_communication/web_rtc_3/media/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc_3/media/open_user_media.dart';
import 'package:xapptor_communication/web_rtc_3/media/set_local_video_renderer.dart';
import 'package:xapptor_communication/web_rtc_3/settings/menu.dart';

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
  final TextEditingController call_id_controller = TextEditingController();

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

  ValueNotifier<bool> enable_audio = ValueNotifier<bool>(true);
  ValueNotifier<bool> enable_video = ValueNotifier<bool>(true);

  ValueNotifier<List<MediaDeviceInfo>> audio_devices = ValueNotifier<List<MediaDeviceInfo>>([]);
  ValueNotifier<List<MediaDeviceInfo>> video_devices = ValueNotifier<List<MediaDeviceInfo>>([]);
  ValueNotifier<String> current_audio_device = ValueNotifier<String>("");
  ValueNotifier<String> current_video_device = ValueNotifier<String>("");
  ValueNotifier<String> current_audio_device_id = ValueNotifier<String>("");
  ValueNotifier<String> current_video_device_id = ValueNotifier<String>("");

  ValueNotifier<bool> mirror_local_renderer = ValueNotifier<bool>(true);
  ValueNotifier<double> zoom = ValueNotifier<double>(0);

  ValueNotifier<RTCVideoRenderer> local_renderer = ValueNotifier<RTCVideoRenderer>(RTCVideoRenderer());
  ValueNotifier<List<RemoteRenderer>> remote_renderers = ValueNotifier<List<RemoteRenderer>>([]);

  TextEditingController room_id_controller = TextEditingController();

  ValueNotifier<bool> show_qr_scanner = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_settings = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_info = ValueNotifier<bool>(false);
  ValueNotifier<bool> share_screen = ValueNotifier<bool>(false);
  ValueNotifier<int> call_participants = ValueNotifier<int>(1);
  ValueNotifier<bool> in_a_call = ValueNotifier<bool>(false);
  ValueNotifier<StreamSubscription?> connections_listener = ValueNotifier(null);
  //ValueNotifier<Room>? room;

  video_callback(String new_value) {
    set_local_video_renderer(
      new_value: new_value,
      video_devices: video_devices,
      current_video_device: current_video_device,
      current_video_device_id: current_video_device_id,
      current_audio_device_id: current_audio_device_id,
      local_video_renderer: local_video_renderer,
      enable_video: enable_video,
      enable_audio: enable_audio,
    );
  }

  audio_callback() {
    local_video_renderer.srcObject?.getAudioTracks().forEach((audio_track) {
      audio_track.stop();
    });
    open_user_media(
      current_video_device_id: current_video_device_id,
      current_audio_device_id: current_audio_device_id,
      enable_video: enable_video,
      enable_audio: enable_audio,
      local_video_renderer: local_video_renderer,
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize_renderers();
  }

  void _initialize_renderers() async {
    await get_media_devices(
      callback: () {
        open_user_media(
          current_video_device_id: current_video_device_id,
          current_audio_device_id: current_audio_device_id,
          enable_video: enable_video,
          enable_audio: enable_audio,
          local_video_renderer: local_video_renderer,
        );
      },
      audio_devices: audio_devices,
      video_devices: video_devices,
      current_audio_device: current_audio_device,
      current_video_device: current_video_device,
      current_audio_device_id: current_audio_device_id,
      current_video_device_id: current_video_device_id,
      mirror_local_renderer: mirror_local_renderer,
    );
    await local_video_renderer.initialize();
    await remote_video_renderer.initialize();
  }

  @override
  void dispose() {
    local_video_renderer.dispose();
    remote_video_renderer.dispose();
    call_id_controller.dispose();
    peer_connection.close();
    local_stream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Flutter WebRTC Demo")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: RTCVideoView(
                      local_video_renderer,
                      mirror: true,
                    )),
                    Expanded(
                      child: RTCVideoView(
                        remote_video_renderer,
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: call_id_controller,
                decoration: const InputDecoration(
                  labelText: 'Enter Call ID',
                ),
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
                    child: const Text("Enter Call"),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  show_settings.value = !show_settings.value;
                  setState(() {});
                },
              ),
            ],
          ),
          if (show_settings.value)
            Container(
              constraints: BoxConstraints(
                minHeight: height * 0.2,
                minWidth: width * 0.2,
                maxHeight: height * 0.45,
                maxWidth: width * 0.8,
              ),
              child: SettingsMenu(
                background_color: Colors.blueGrey.withValues(alpha: 0.95),
                close_callback: () {
                  show_settings.value = !show_settings.value;
                  setState(() {});
                },
                video_button_callback: video_callback,
                audio_button_callback: audio_callback,
                audio_devices: audio_devices,
                video_devices: video_devices,
                current_audio_device: current_audio_device,
                current_video_device: current_video_device,
                current_audio_device_id: current_audio_device_id,
                current_video_device_id: current_video_device_id,
                zoom: zoom,
                local_video_renderer: local_video_renderer,
                mirror_local_renderer: mirror_local_renderer,
              ),
            ),
          // if (show_info)
          //   FractionallySizedBox(
          //     heightFactor: portrait ? 0.7 : 0.5,
          //     widthFactor: portrait ? 0.9 : 0.5,
          //     child: RoomInfo(
          //       background_color: Colors.blueGrey.withValues(alpha: 0.9),
          //       main_color: Colors.blue,
          //       room_id: call_id_controller.text,
          //       call_base_url: "call_base_url_default",
          //       callback: () {
          //         show_info = !show_info;
          //         setState(() {});
          //       },
          //       parent_context: context,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
