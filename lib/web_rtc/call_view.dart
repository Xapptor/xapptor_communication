import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc/grid_video_view.dart';
import 'package:xapptor_communication/web_rtc/settings_menu.dart';
import 'package:xapptor_communication/web_rtc/signaling.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'custom_dropdown_button.dart';
import 'join_another_room_container.dart';
import 'remote_renderer.dart';
import 'room_info.dart';
import 'settings_icons.dart';

class CallView extends StatefulWidget {
  const CallView({
    required this.main_color,
    required this.background_color,
    required this.enable_audio,
    required this.enable_video,
    required this.text_list,
    required this.call_base_url,
    required this.room_id,
  });

  final Color main_color;
  final Color background_color;
  final bool enable_audio;
  final bool enable_video;
  final List<String> text_list;
  final String call_base_url;
  final String room_id;

  @override
  _CallViewState createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  ValueNotifier<bool> enable_audio = ValueNotifier<bool>(true);
  ValueNotifier<bool> enable_video = ValueNotifier<bool>(true);

  Signaling signaling = Signaling();
  RTCVideoRenderer local_renderer = RTCVideoRenderer();
  List<RemoteRenderer> remote_renderers = [];

  TextEditingController room_id_controller = TextEditingController();

  List<MediaDeviceInfo> audio_devices = [];
  List<MediaDeviceInfo> video_devices = [];
  String current_audio_device = "";
  String current_video_device = "";
  String current_audio_device_id = "";
  String current_video_device_id = "";

  ValueNotifier<bool> show_qr_scanner = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_settings = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_info = ValueNotifier<bool>(false);
  ValueNotifier<int> call_participants = ValueNotifier<int>(1);
  ValueNotifier<bool> in_a_call = ValueNotifier<bool>(false);

  String room_id = "";

  late FirebaseFirestore db;

  listen_call_participants() {
    db = FirebaseFirestore.instance;

    if (room_id != "") {
      DocumentReference room_ref = db.collection('rooms').doc(room_id);

      room_ref.collection('calleeCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            remote_renderers.last.call_id = change.doc.id;
          } else if (change.type == DocumentChangeType.removed) {
            print("removed__00");
            remote_renderers
                .removeWhere((element) => element.call_id == change.doc.id);
          }
        });
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    room_id = widget.room_id;
    init_video_renderers();
    super.initState();
    listen_call_participants();
    call_open_user_media().then((_) {
      get_media_devices().then((_) async {
        set_media_devices_enabled();
      });
    });
  }

  set_media_devices_enabled() {
    enable_audio.value = widget.enable_audio;
    enable_video.value = widget.enable_video;
    call_open_user_media();
    setState(() {});
  }

  Future call_open_user_media() async {
    RTCVideoRenderer? remote_renderer;
    if (remote_renderers.length > 0) {
      remote_renderers.first.video_renderer;
    }
    await signaling.open_user_media(
      local_renderer: local_renderer,
      remote_renderer: remote_renderer,
      audio_device_id: current_audio_device_id,
      video_device_id: current_video_device_id,
      enable_audio: enable_audio.value,
      enable_video: enable_video.value,
    );
  }

  @override
  void dispose() {
    local_renderer.dispose();
    remote_renderers.forEach((element) {
      element.video_renderer.dispose();
    });
    super.dispose();
  }

  add_remote_renderer() {
    RTCVideoRenderer video_renderer = RTCVideoRenderer();
    video_renderer.initialize();

    remote_renderers.add(
      RemoteRenderer(
        video_renderer: video_renderer,
        call_id: "",
      ),
    );
  }

  init_video_renderers() {
    local_renderer.initialize();

    signaling.on_add_remote_stream = ((stream) {
      print("_case_2");
      add_remote_renderer();
      remote_renderers.last.video_renderer.srcObject = stream;
      setState(() {});
    });
  }

  Future get_media_devices() async {
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

  CustomDropdownButton audio_dropdown_button() {
    return CustomDropdownButton(
      value: current_audio_device,
      on_changed: (new_value) {
        current_audio_device = new_value!;
        current_audio_device_id = audio_devices
            .firstWhere((element) => element.label == new_value)
            .deviceId;

        local_renderer.srcObject?.getAudioTracks().forEach((element) {
          element.stop();
        });

        call_open_user_media();
        setState(() {});
      },
      items: audio_devices.map((e) => e.label).toList(),
      title: widget.text_list[0],
    );
  }

  CustomDropdownButton video_dropdown_button() {
    return CustomDropdownButton(
      value: current_video_device,
      on_changed: (new_value) {
        current_video_device = new_value!;
        current_video_device_id = video_devices
            .firstWhere((element) => element.label == new_value)
            .deviceId;

        local_renderer.srcObject?.getVideoTracks().forEach((element) {
          element.stop();
        });

        call_open_user_media();
        setState(() {});
      },
      items: video_devices.map((e) => e.label).toList(),
      title: widget.text_list[1],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        show_qr_scanner.value
            ? QRScanner(
                descriptive_text: "Frame the QR code",
                update_qr_value: (new_value) {
                  room_id_controller.text = new_value;
                  show_qr_scanner.value = false;

                  if (enable_video.value) {
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
            : GestureDetector(
                onTap: () {
                  if (show_settings.value) {
                    show_settings.value = false;
                    show_info.value = false;
                    setState(() {});
                  }
                },
                child: Container(
                  height: screen_height,
                  width: screen_width,
                  //color: Colors.red,
                  child: SingleChildScrollView(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: portrait
                            ? 0.9
                            : in_a_call.value
                                ? 0.65
                                : 0.5,
                        child: Column(
                          children: [
                            GridVideoView(
                              local_renderer: local_renderer,
                              remote_renderers: remote_renderers,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SettingsIcons(
                                main_color: widget.main_color,
                                enable_audio: enable_audio,
                                enable_video: enable_video,
                                local_renderer: local_renderer,
                                show_settings: show_settings,
                                show_info: show_info,
                                call_open_user_media: call_open_user_media,
                                setState: setState,
                                in_a_call: in_a_call,
                              ),
                            ),
                            in_a_call.value
                                ? Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: FloatingActionButton(
                                          child: Icon(Icons.call_end),
                                          backgroundColor: Colors.red,
                                          onPressed: () {
                                            signaling
                                                .hang_up(local_renderer)
                                                .then((value) {
                                              remote_renderers.clear();
                                              in_a_call.value = false;
                                              room_id_controller.clear();
                                              room_id = "";
                                              setState(() {});
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      audio_dropdown_button(),
                                      video_dropdown_button(),
                                      JoinAnotherRoomContainer(
                                        text_list: widget.text_list,
                                        local_renderer: local_renderer,
                                        show_qr_scanner: show_qr_scanner,
                                        setState: setState,
                                        main_color: widget.main_color,
                                        join_room: () {
                                          room_id = room_id_controller.text;
                                          signaling.join_room(room_id);
                                          in_a_call.value = !in_a_call.value;
                                          listen_call_participants();
                                          setState(() {});
                                        },
                                        room_id_controller: room_id_controller,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 40,
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  widget.main_color,
                                            ),
                                            onPressed: () async {
                                              room_id =
                                                  await signaling.create_room();
                                              in_a_call.value =
                                                  !in_a_call.value;
                                              listen_call_participants();
                                              setState(() {});
                                            },
                                            child: Text(
                                              widget.text_list.last,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
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
                  ),
                ),
              ),
        show_settings.value
            ? FractionallySizedBox(
                heightFactor: portrait ? 0.9 : 0.7,
                widthFactor: portrait ? 0.9 : 0.5,
                child: SettingsMenu(
                  background_color: Colors.blueGrey.withOpacity(0.9),
                  audio_dropdown_button: audio_dropdown_button(),
                  video_dropdown_button: video_dropdown_button(),
                  callback: () {
                    show_settings.value = !show_settings.value;
                    setState(() {});
                  },
                ),
              )
            : Container(),
        show_info.value
            ? FractionallySizedBox(
                heightFactor: portrait ? 0.7 : 0.5,
                widthFactor: portrait ? 0.9 : 0.5,
                child: RoomInfo(
                  background_color: Colors.blueGrey.withOpacity(0.9),
                  main_color: widget.main_color,
                  room_id: room_id,
                  call_base_url: widget.call_base_url,
                  callback: () {
                    show_info.value = !show_info.value;
                    setState(() {});
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}
