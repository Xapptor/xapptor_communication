import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';
import 'create_room.dart';
import 'hang_up.dart';
import 'join_room.dart';
import 'open_user_media.dart';
import 'signaling.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Call extends StatefulWidget {
  Call({
    required this.main_color,
    required this.background_color,
  });

  final Color main_color;
  final Color background_color;

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {
  TextEditingController room_id_controller = TextEditingController();
  RTCVideoRenderer local_renderer = RTCVideoRenderer();
  RTCVideoRenderer remote_renderer = RTCVideoRenderer();
  MediaStream? local_stream;
  MediaStream? remote_stream;
  String room_id = "";

  bool show_qr_scanner = false;

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
  String? current_room_text;
  StreamStateCallback? on_add_remote_stream;

  init_video_renderers() {
    local_renderer.initialize();
    remote_renderer.initialize();

    on_add_remote_stream = ((stream) {
      remote_renderer.srcObject = stream;
      setState(() {});
    });
  }

  @override
  void initState() {
    init_video_renderers();
    super.initState();
  }

  @override
  void dispose() {
    local_renderer.dispose();
    remote_renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return show_qr_scanner
        ? QRScanner(
            descriptive_text: "Frame the QR code",
            update_qr_value: (new_value) {
              room_id_controller.text = new_value;
              show_qr_scanner = false;
              setState(() {});
            },
            border_color: widget.main_color,
            border_radius: 4,
            border_length: 40,
            border_width: 8,
            cut_out_size: 300,
            button_linear_gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.4),
                Colors.green.withOpacity(0.4),
              ],
            ),
            permission_message:
                "You must give the camera permission to capture QR codes",
            permission_message_no: "Cancel",
            permission_message_yes: "Accept",
            enter_code_text: "Enter your code",
            validate_button_text: "Validate",
            fail_message: "You have to enter a code",
            textfield_color: Colors.green,
            show_main_button: false,
            main_button_text: "Button",
            main_button_function: () => null,
          )
        : Container(
            color: widget.background_color,
            child: ListView(
              children: [
                SizedBox(height: 12),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          open_user_media(
                            local_video: local_renderer,
                            remote_video: remote_renderer,
                            local_stream: local_stream,
                          );
                          setState(() {});
                        },
                        child: Text("Open camera & microphone"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          room_id = await create_room(
                            remote_renderer: remote_renderer,
                            configuration: configuration,
                            peer_connection: peer_connection,
                            local_stream: local_stream,
                            remote_stream: remote_stream,
                            current_room_text: current_room_text,
                            on_add_remote_stream: on_add_remote_stream,
                          );
                          room_id_controller.text = room_id;
                          setState(() {});
                        },
                        child: Text("Create room"),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add roomId
                          join_room(
                            room_id: room_id_controller.text,
                            remote_video: remote_renderer,
                            configuration: configuration,
                            peer_connection: peer_connection,
                            local_stream: local_stream,
                            remote_stream: remote_stream,
                            on_add_remote_stream: on_add_remote_stream,
                          );
                        },
                        child: Text("Join room"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          hang_up(
                            local_video: local_renderer,
                            local_stream: local_stream,
                            remote_stream: remote_stream,
                            peer_connection: peer_connection,
                            room_id: room_id,
                          );
                        },
                        child: Text("Hangup"),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: screen_height / 1.8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.orange,
                            child: RTCVideoView(
                              local_renderer,
                              mirror: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.cyan,
                            child: RTCVideoView(
                              remote_renderer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Join the following Room:",
                                  textAlign: TextAlign.left,
                                ),
                                IconButton(
                                  onPressed: () {
                                    show_qr_scanner = true;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: widget.main_color,
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: room_id_controller,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: room_id_controller.text.isNotEmpty
                            ? QrImage(
                                data: room_id_controller.text,
                                version: QrVersions.auto,
                                size: 200.0,
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
