import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc/signaling.dart';
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
  });

  final Color main_color;
  final Color background_color;
  final Signaling signaling;
  RTCVideoRenderer local_renderer;
  RTCVideoRenderer remote_renderer;
  bool enable_audio = false;
  bool enable_video = false;
  final List<String> text_list;

  @override
  _InitialCallViewState createState() => _InitialCallViewState();
}

class _InitialCallViewState extends State<InitialCallView> {
  RTCVideoRenderer local_renderer_without_video = RTCVideoRenderer();

  List<MediaDeviceInfo> audio_devices = [];
  List<MediaDeviceInfo> video_devices = [];
  String current_audio_device = "";
  String current_video_device = "";

  @override
  void initState() {
    init_video_renderers();
    super.initState();
    call_open_user_media("").then((_) {
      get_media_devices();
    });
  }

  Future<void> call_open_user_media(String device_id) async {
    if (widget.enable_audio || widget.enable_video) {
      await widget.signaling.open_user_media(
        local_renderer: widget.local_renderer,
        remote_renderer: widget.remote_renderer,
        device_id: device_id,
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
    current_audio_device = audio_devices.first.label;
    current_video_device = video_devices.first.label;
    setState(() {});

    video_devices.forEach((element) {
      print(element.label);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    return Container(
      alignment: Alignment.center,
      color: widget.background_color,
      child: FractionallySizedBox(
        widthFactor: portrait ? 0.9 : 0.5,
        child: Column(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 8,
              child: Container(
                color: widget.background_color,
                child: RTCVideoView(
                  widget.local_renderer,
                  mirror: true,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              widget.enable_audio ? Icons.mic : Icons.mic_off,
                              color: widget.main_color,
                            ),
                            onPressed: () {
                              setState(() {
                                widget.enable_audio = !widget.enable_audio;
                                if (widget.enable_audio) {
                                  widget.local_renderer.muted = false;
                                } else {
                                  widget.local_renderer.muted = true;
                                }
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
                              setState(() {
                                widget.enable_video = !widget.enable_video;
                              });
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
                          });

                          String current_device_id = audio_devices
                              .firstWhere((element) =>
                                  element.label == current_audio_device)
                              .deviceId;

                          call_open_user_media(current_device_id);
                        },
                        items: audio_devices
                            .map((e) => e.label)
                            .map<DropdownMenuItem<String>>((String value) {
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
                        onChanged: (String? new_value) {
                          setState(() {
                            current_video_device = new_value!;
                          });

                          String current_device_id = video_devices
                              .firstWhere((element) =>
                                  element.label == current_video_device)
                              .deviceId;

                          call_open_user_media(current_device_id);
                        },
                        items: video_devices
                            .map((e) => e.label)
                            .map<DropdownMenuItem<String>>((String value) {
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.main_color,
                      ),
                      onPressed: () {},
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
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
