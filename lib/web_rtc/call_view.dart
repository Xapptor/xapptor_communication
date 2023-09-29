// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/get_media_devices.dart';
import 'package:xapptor_communication/web_rtc/grid_video_view.dart';
import 'package:xapptor_communication/web_rtc/listen_connections.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart' as CommunicationUser;
import 'package:xapptor_communication/web_rtc/settings_menu.dart';
import 'package:xapptor_communication/web_rtc/show_exit_alert.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_offer.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc/signaling/open_user_media.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/join_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/hang_up.dart';
import 'package:xapptor_router/update_path/update_path.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'add_remote_renderer.dart';
import 'custom_dropdown_button.dart';
import 'join_another_room_container.dart';
import 'model/remote_renderer.dart';
import 'room_info.dart';
import 'settings_icons.dart';
import 'signaling/model/room.dart';
import 'package:xapptor_router/get_last_path_segment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallView extends StatefulWidget {
  final Color main_color;
  final Color background_color;
  final bool enable_audio;
  final bool enable_video;
  final List<String> text_list;
  final String call_base_url;
  ValueNotifier<String> room_id;
  String user_id;
  String user_name;
  final String logo_path;

  CallView({
    super.key,
    required this.main_color,
    required this.background_color,
    required this.enable_audio,
    required this.enable_video,
    required this.text_list,
    required this.call_base_url,
    required this.room_id,
    required this.user_id,
    required this.user_name,
    required this.logo_path,
  });

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  ValueNotifier<bool> enable_audio = ValueNotifier<bool>(true);
  ValueNotifier<bool> enable_video = ValueNotifier<bool>(true);
  ValueNotifier<List<MediaDeviceInfo>> audio_devices = ValueNotifier<List<MediaDeviceInfo>>([]);
  ValueNotifier<List<MediaDeviceInfo>> video_devices = ValueNotifier<List<MediaDeviceInfo>>([]);

  Signaling signaling = Signaling();
  RTCVideoRenderer local_renderer = RTCVideoRenderer();
  ValueNotifier<List<RemoteRenderer>> remote_renderers = ValueNotifier<List<RemoteRenderer>>([]);

  ValueNotifier<bool> mirror_local_renderer = ValueNotifier<bool>(true);

  TextEditingController room_id_controller = TextEditingController();
  ValueNotifier<String> current_audio_device = ValueNotifier<String>("");
  ValueNotifier<String> current_video_device = ValueNotifier<String>("");
  ValueNotifier<String> current_audio_device_id = ValueNotifier<String>("");
  ValueNotifier<String> current_video_device_id = ValueNotifier<String>("");
  ValueNotifier<bool> show_qr_scanner = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_settings = ValueNotifier<bool>(false);
  ValueNotifier<bool> show_info = ValueNotifier<bool>(false);
  ValueNotifier<bool> share_screen = ValueNotifier<bool>(false);
  ValueNotifier<int> call_participants = ValueNotifier<int>(1);
  ValueNotifier<bool> in_a_call = ValueNotifier<bool>(false);
  ValueNotifier<StreamSubscription?> connections_listener = ValueNotifier(null);
  Room? room;

  @override
  void initState() {
    super.initState();
    check_if_user_is_logged_in();
  }

  check_if_user_is_logged_in() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      widget.user_id = user.uid;
      CommunicationUser.User communication_user = await CommunicationUser.get_user_from_id(user.uid);
      widget.user_name = communication_user.name;

      signaling.init(user_id: widget.user_id);
      init_video_renderers();

      if (widget.room_id.value == '') {
        widget.room_id.value = get_last_path_segment();
      }

      if (widget.room_id.value != "" && widget.room_id.value != "room" && widget.room_id.value.length > 6) {
        join_room(widget.room_id.value);
      }

      call_open_user_media().then((_) {
        get_media_devices(
          audio_devices: audio_devices,
          video_devices: video_devices,
          current_audio_device: current_audio_device,
          current_audio_device_id: current_audio_device_id,
          current_video_device: current_video_device,
          current_video_device_id: current_video_device_id,
          callback: () {
            setState(() {});
          },
        ).then((_) async {
          set_media_devices_enabled();
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  set_media_devices_enabled() {
    enable_audio.value = widget.enable_audio;
    enable_video.value = widget.enable_video;
    call_open_user_media();
    setState(() {});
  }

  Future call_open_user_media() async {
    RTCVideoRenderer? remote_renderer;
    if (remote_renderers.value.isNotEmpty) {
      remote_renderer = remote_renderers.value.first.video_renderer;
    }
    await signaling.open_user_media(
      local_renderer: local_renderer,
      remote_renderer: remote_renderer,
      audio_device_id: current_audio_device_id.value,
      video_device_id: current_video_device_id.value,
      enable_audio: enable_audio.value,
      enable_video: enable_video.value,
    );
  }

  @override
  void dispose() {
    local_renderer.dispose();
    for (var element in remote_renderers.value) {
      element.video_renderer.dispose();
    }
    if (connections_listener.value != null) {
      connections_listener.value!.cancel();
    }
    super.dispose();
  }

  init_video_renderers() {
    local_renderer.initialize();
    signaling.on_add_remote_stream = ((stream) {
      add_remote_renderer(remote_renderers);
      remote_renderers.value.last.video_renderer.srcObject = stream;
      setState(() {});
    });
  }

  CustomDropdownButton audio_dropdown_button() {
    return CustomDropdownButton(
      value: current_audio_device.value,
      on_changed: (new_value) {
        current_audio_device.value = new_value!;
        current_audio_device_id.value =
            audio_devices.value.firstWhere((element) => element.label == new_value).deviceId;

        local_renderer.srcObject?.getAudioTracks().forEach((element) {
          element.stop();
        });

        call_open_user_media();
        setState(() {});
      },
      items: audio_devices.value.map((e) => e.label).toList(),
      title: widget.text_list[0],
    );
  }

  CustomDropdownButton video_dropdown_button() {
    return CustomDropdownButton(
      value: current_video_device.value,
      on_changed: (new_value) {
        set_local_renderer(new_value!);
      },
      items: video_devices.value.map((e) => e.label).toList(),
      title: widget.text_list[1],
    );
  }

  set_local_renderer(String new_value) {
    current_video_device.value = new_value;
    current_video_device_id.value = video_devices.value.firstWhere((element) => element.label == new_value).deviceId;

    local_renderer.srcObject?.getVideoTracks().forEach((element) {
      element.stop();
    });

    call_open_user_media();
    setState(() {});
  }

  clean_the_room() async {
    if (widget.room_id.value != "") {
      remote_renderers.value.clear();
      DocumentReference room_ref = db.collection('rooms').doc(widget.room_id.value);

      await signaling.create_connection_offer(
        room_ref: room_ref,
        remote_renderers: remote_renderers,
        setState: setState,
      );
      setState(() {});
    }
  }

  exit_from_room({
    required BuildContext context,
    required String message,
  }) {
    remote_renderers.value.clear();
    in_a_call.value = false;
    room_id_controller.clear();
    widget.room_id.value = "";
    setState(() {});
    show_exit_alert(
      context: context,
      message: message,
    );
    update_path('home/room');
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    return SafeArea(
      child: Scaffold(
        appBar: TopBar(
          context: context,
          background_color: widget.main_color,
          actions: [],
          has_back_button: true,
          custom_leading: null,
          logo_path: widget.logo_path,
        ),
        body: Stack(
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
                    permission_message: "You must give the camera permission to capture QR codes",
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
                    child: SizedBox(
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
                                  mirror_local_renderer: mirror_local_renderer.value,
                                  user_name: widget.user_name,
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
                                    share_screen: share_screen,
                                    call_open_user_media: call_open_user_media,
                                    setState: setState,
                                    in_a_call: in_a_call,
                                    stop_screen_share_function: () {
                                      set_local_renderer(current_video_device.value);
                                    },
                                    mirror_local_renderer: mirror_local_renderer,
                                  ),
                                ),
                                in_a_call.value
                                    ? Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: FloatingActionButton(
                                              backgroundColor: Colors.red,
                                              onPressed: () async {
                                                String message = '';
                                                if (widget.user_id == room!.host_id) {
                                                  message = 'You closed the room';
                                                } else {
                                                  message = 'You exit the room';
                                                }

                                                await connections_listener.value!.cancel();
                                                await signaling.hang_up();
                                                exit_from_room(
                                                  context: context,
                                                  message: message,
                                                );
                                              },
                                              child: const Icon(Icons.call_end),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          audio_dropdown_button(),
                                          video_dropdown_button(),
                                          JoinAnotherRoomContainer(
                                            text_list: widget.text_list,
                                            local_renderer: local_renderer,
                                            show_qr_scanner: show_qr_scanner,
                                            setState: setState,
                                            main_color: widget.main_color,
                                            join_room: () async {
                                              if (room_id_controller.text.contains('https://xapptor.com/home/room/')) {
                                                widget.room_id.value =
                                                    room_id_controller.text.split('https://xapptor.com/home/room/')[1];
                                              } else {
                                                widget.room_id.value = room_id_controller.text;
                                              }

                                              join_room(widget.room_id.value);
                                            },
                                            room_id_controller: room_id_controller,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              height: 40,
                                              margin: const EdgeInsets.only(top: 20),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: widget.main_color,
                                                ),
                                                onPressed: () async {
                                                  create_room();
                                                },
                                                child: Text(
                                                  widget.text_list.last,
                                                  style: const TextStyle(
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
                      room_id: widget.room_id.value,
                      call_base_url: widget.call_base_url,
                      callback: () {
                        show_info.value = !show_info.value;
                        setState(() {});
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  create_room() async {
    if (room_id_controller.text.isEmpty) {
      room = await signaling.create_room(
        context: context,
        remote_renderers: remote_renderers,
        setState: setState,
      );
      widget.room_id.value = room!.id;

      in_a_call.value = true;
      listen_connections(
        user_id: widget.user_id,
        remote_renderers: remote_renderers,
        setState: setState,
        signaling: signaling,
        clean_the_room: clean_the_room,
        exit_from_room: exit_from_room,
        connections_listener: connections_listener,
        context: context,
        room: room!,
      );
      update_path('home/room/${widget.room_id.value}');
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Room ID musty be empty to create a room',
          ),
        ),
      );
    }
  }

  join_room(String room_id) async {
    await signaling.join_room(
      room_id: widget.room_id.value,
      remote_renderers: remote_renderers,
      setState: setState,
    );
    in_a_call.value = true;

    DocumentSnapshot room_snap = await db.collection('rooms').doc(widget.room_id.value).get();

    room = Room.from_snapshot(room_snap.id, room_snap.data() as Map<String, dynamic>);

    listen_connections(
      user_id: widget.user_id,
      remote_renderers: remote_renderers,
      setState: setState,
      signaling: signaling,
      clean_the_room: clean_the_room,
      exit_from_room: exit_from_room,
      connections_listener: connections_listener,
      context: context,
      room: room!,
    );
    update_path('home/room/${widget.room_id.value}');
    setState(() {});
  }
}
