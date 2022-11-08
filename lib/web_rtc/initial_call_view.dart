import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view.dart';
import 'package:xapptor_communication/web_rtc/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc/signaling.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

class InitialCallView extends StatefulWidget {
  InitialCallView({
    required this.main_color,
    required this.background_color,
    required this.signaling,
    required this.local_renderer,
    required this.remote_renderer,
    required this.enable_audio,
    required this.enable_video,
    required this.text_list,
    required this.call_base_url,
  });

  final Color main_color;
  final Color background_color;
  final Signaling signaling;
  RTCVideoRenderer local_renderer;
  RTCVideoRenderer remote_renderer;
  bool enable_audio = false;
  bool enable_video = false;
  final List<String> text_list;
  final String call_base_url;

  @override
  _InitialCallViewState createState() => _InitialCallViewState();
}

class _InitialCallViewState extends State<InitialCallView> {
  TextEditingController room_id_controller = TextEditingController();
  RTCVideoRenderer local_renderer_without_video = RTCVideoRenderer();

  List<MediaDeviceInfo> audio_devices = [];
  List<MediaDeviceInfo> video_devices = [];
  String current_audio_device = "";
  String current_video_device = "0";
  String current_audio_device_id = "";
  String current_video_device_id = "";

  String room_id = "";
  bool show_qr_scanner = false;

  @override
  void initState() {
    init_video_renderers();
    super.initState();

    call_open_user_media().then((_) {
      get_media_devices();
    });
  }

  Future<void> call_open_user_media() async {
    if (widget.enable_audio || widget.enable_video) {
      await widget.signaling.open_user_media(
        local_renderer: widget.local_renderer,
        remote_renderer: widget.remote_renderer,
        audio_device_id: current_audio_device_id,
        video_device_id: current_video_device_id,
        enable_audio: widget.enable_audio,
        enable_video: widget.enable_video,
      );
    }
  }

  @override
  void dispose() {
    widget.local_renderer.dispose();
    widget.remote_renderer.dispose();
    super.dispose();
  }

  init_video_renderers() {
    widget.local_renderer.initialize();
    widget.remote_renderer.initialize();

    widget.signaling.on_add_remote_stream = ((stream) {
      widget.remote_renderer.srcObject = stream;
      setState(() {});
    });
  }

  get_media_devices() async {
    audio_devices = await get_audio_devices();
    video_devices = await get_video_devices();

    if (audio_devices.length > 0) {
      current_audio_device = audio_devices[0].label;
      current_audio_device_id = audio_devices[0].deviceId;
    }

    if (video_devices.length > 0) {
      current_video_device = video_devices[0].label;
      current_video_device_id = video_devices[0].deviceId;
    }
    setState(() {});
  }

  join_room(bool room_id_was_created) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CallView(
            signaling: widget.signaling,
            local_renderer: widget.local_renderer,
            remote_renderer: widget.remote_renderer,
            main_color: widget.main_color,
            background_color: widget.background_color,
            text_list: widget.text_list,
            enable_audio: widget.enable_audio,
            enable_video: widget.enable_video,
            room_id: room_id,
            room_id_was_created: room_id_was_created,
            call_base_url: widget.call_base_url,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    return show_qr_scanner
        ? QRScanner(
            descriptive_text: "Frame the QR code",
            update_qr_value: (new_value) {
              room_id_controller.text = new_value;
              show_qr_scanner = false;

              if (widget.enable_video) {
                call_open_user_media();
              }
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
        : SingleChildScrollView(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: portrait ? 0.9 : 0.5,
                child: Column(
                  children: [
                    Container(
                      height: screen_height * 0.3,
                      child: RTCVideoView(
                        widget.local_renderer,
                        mirror: true,
                      ),
                    ),
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    widget.enable_audio
                                        ? Icons.mic
                                        : Icons.mic_off,
                                    color: widget.main_color,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      widget.enable_audio =
                                          !widget.enable_audio;
                                      widget.local_renderer.muted =
                                          !widget.enable_audio;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    widget.enable_video
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                    color: widget.main_color,
                                  ),
                                  onPressed: () {
                                    widget.enable_video = !widget.enable_video;

                                    if (widget.local_renderer.srcObject !=
                                        null) {
                                      if (widget.local_renderer.srcObject!
                                              .getVideoTracks()
                                              .length >
                                          0) {
                                        widget.local_renderer.srcObject
                                            ?.getVideoTracks()[0]
                                            .enabled = widget.enable_video;
                                      } else {
                                        call_open_user_media();
                                      }
                                    } else {
                                      call_open_user_media();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(
                                widget.text_list[0],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: current_audio_device,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? new_value) {
                                setState(() {
                                  current_audio_device = new_value!;
                                  current_audio_device_id = audio_devices
                                      .firstWhere((element) =>
                                          element.label == current_audio_device)
                                      .deviceId;
                                });

                                call_open_user_media();
                              },
                              items: audio_devices
                                  .map((e) => e.label)
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(
                                widget.text_list[1],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: current_video_device,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? new_value) async {
                                var video_tracks = widget
                                    .local_renderer.srcObject
                                    ?.getVideoTracks();

                                setState(() {
                                  current_video_device = new_value!;
                                  current_video_device_id = video_devices
                                      .firstWhere((element) =>
                                          element.label == current_video_device)
                                      .deviceId;
                                });

                                await Helper.switchCamera(
                                  video_tracks!.first,
                                  current_video_device_id,
                                  widget.local_renderer.srcObject,
                                );
                              },
                              items: video_devices
                                  .map((e) => e.label)
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Text(
                                widget.text_list[widget.text_list.length - 4],
                                textAlign: TextAlign.left,
                              ),
                              UniversalPlatform.isWeb
                                  ? Container()
                                  : IconButton(
                                      onPressed: () {
                                        widget.local_renderer.srcObject
                                            ?.getVideoTracks()
                                            .forEach((element) {
                                          element.stop();
                                        });

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
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              width: screen_width * (portrait ? 0.4 : 0.2),
                              child: TextFormField(
                                controller: room_id_controller,
                                decoration: InputDecoration(
                                  hintText: widget
                                      .text_list[widget.text_list.length - 3],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.main_color,
                              ),
                              onPressed: () async {
                                room_id = room_id_controller.text;
                                setState(() {});
                                join_room(false);
                              },
                              child: Text(
                                widget.text_list[widget.text_list.length - 2],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.main_color,
                            ),
                            onPressed: () async {
                              room_id = await widget.signaling
                                  .create_room(widget.local_renderer);
                              setState(() {});
                              join_room(true);
                            },
                            child: Text(
                              widget.text_list.last,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
