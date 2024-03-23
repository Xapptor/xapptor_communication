// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view_wrapper.dart';
import 'package:xapptor_communication/web_rtc/call_view/check_if_user_is_logged_in.dart';
import 'package:xapptor_communication/web_rtc/call_view/check_permissions.dart';
import 'package:xapptor_communication/web_rtc/call_view/create_room_button.dart';
import 'package:xapptor_communication/web_rtc/call_view/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/floating_menus.dart';
import 'package:xapptor_communication/web_rtc/call_view/join_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/qr_scanner.dart';
import 'package:xapptor_communication/web_rtc/call_view/set_local_renderer.dart';
import 'package:xapptor_communication/web_rtc/call_view/video_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc/grid_video_view.dart';
import 'package:xapptor_communication/web_rtc/join_another_room_container.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/settings_icons.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc/signaling/hang_up.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

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
  ValueNotifier<double> zoom = ValueNotifier<double>(0);

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
  ValueNotifier<Room>? room;

  @override
  void initState() {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) mirror_local_renderer.value = false;
    enable_audio.value = widget.enable_audio;
    enable_video.value = widget.enable_video;
    super.initState();
    check_permissions();
    check_if_user_is_logged_in();
  }

  @override
  void dispose() {
    local_renderer.srcObject?.getVideoTracks().forEach((track) => track.stop());
    local_renderer.dispose();

    for (var remote_renderer in remote_renderers.value) {
      remote_renderer.video_renderer.dispose();
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

    return call_view_wrapper(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
              show_qr_scanner.value
                  ? qr_scanner()
                  : SizedBox(
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
                                  user_id: widget.user_id,
                                  room: room,
                                  enable_video: enable_video,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: settings_icons(
                                    stop_screen_share_function: () {
                                      set_local_renderer(current_video_device.value);
                                    },
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
                                                await signaling.hang_up(
                                                    context: context,
                                                    room: room!,
                                                    user_id: widget.user_id,
                                                    connections_listener: connections_listener,
                                                    exit_from_room: () {
                                                      String message = '';
                                                      if (widget.user_id == room!.value.host_id) {
                                                        message = 'You closed the room';
                                                      } else {
                                                        message = 'You exit the room';
                                                      }

                                                      if (context.mounted) {
                                                        exit_from_room(
                                                          message: message,
                                                        );
                                                      }
                                                      ROOM_CREATOR_RANDOM_ID = "";
                                                      room = null;
                                                      setState(() {});
                                                    });
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
                                              if (room_id_controller.text.contains(widget.call_base_url)) {
                                                widget.room_id.value =
                                                    room_id_controller.text.split(widget.call_base_url)[1];
                                              } else {
                                                widget.room_id.value = room_id_controller.text;
                                              }

                                              join_room(widget.room_id.value);
                                            },
                                            room_id_controller: room_id_controller,
                                          ),
                                          create_room_button(),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ] +
            floating_menus(portrait: portrait),
      ),
    );
  }
}
