// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/call_view/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/check_if_user_is_logged_in.dart';
import 'package:xapptor_communication/web_rtc/call_view/create_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/join_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/qr_scanner.dart';
import 'package:xapptor_communication/web_rtc/call_view/set_local_renderer.dart';
import 'package:xapptor_communication/web_rtc/call_view/video_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/grid_video_view.dart';
import 'package:xapptor_communication/web_rtc/join_another_room_container.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/room_info.dart';
import 'package:xapptor_communication/web_rtc/settings_icons.dart';
import 'package:xapptor_communication/web_rtc/settings_menu.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc/signaling/hang_up.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'package:xapptor_ui/widgets/topbar.dart';

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
  State<CallView> createState() => CallViewState();
}

class CallViewState extends State<CallView> {
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

  set_media_devices_enabled() {
    enable_audio.value = widget.enable_audio;
    enable_video.value = widget.enable_video;
    call_open_user_media();
    setState(() {});
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
                ? qr_scanner()
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

                                                if (context.mounted) {
                                                  exit_from_room(
                                                    message: message,
                                                  );
                                                }
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
}
