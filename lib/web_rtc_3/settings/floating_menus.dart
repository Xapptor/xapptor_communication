// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/room/room_info.dart';
import 'package:xapptor_communication/web_rtc_3/settings/menu.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

class SettingsIcons extends StatefulWidget {
  final Color background_color;
  final VoidCallback close_callback;
  final Function(String new_value) video_button_callback;
  final VoidCallback audio_button_callback;
  final ValueNotifier<List<MediaDeviceInfo>> audio_devices;
  final ValueNotifier<List<MediaDeviceInfo>> video_devices;
  final ValueNotifier<String> current_audio_device;
  final ValueNotifier<String> current_video_device;
  final ValueNotifier<String> current_audio_device_id;
  final ValueNotifier<String> current_video_device_id;
  final ValueNotifier<double> zoom;
  final RTCVideoRenderer local_video_renderer;
  final ValueNotifier<bool> mirror_local_renderer;
  final Function stop_screen_share_function;
  final ValueNotifier<bool> enable_video;
  final ValueNotifier<bool> enable_audio;
  final ValueNotifier<bool> show_settings;
  final Color main_color;
  final ValueNotifier<bool> share_screen;
  final ValueNotifier<bool> in_a_call;
  final ValueNotifier<bool> show_info;

  const SettingsIcons({
    super.key,
    required this.background_color,
    required this.close_callback,
    required this.video_button_callback,
    required this.audio_button_callback,
    required this.audio_devices,
    required this.video_devices,
    required this.current_audio_device,
    required this.current_video_device,
    required this.current_audio_device_id,
    required this.current_video_device_id,
    required this.zoom,
    required this.local_video_renderer,
    required this.mirror_local_renderer,
    required this.stop_screen_share_function,
    required this.enable_video,
    required this.enable_audio,
    required this.show_settings,
    required this.main_color,
    required this.in_a_call,
    required this.share_screen,
    required this.show_info,
  });

  @override
  State<SettingsIcons> createState() => _SettingsIconsState();
}

class _SettingsIconsState extends State<SettingsIcons> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool portrait = is_portrait(context);

    return [
      if (widget.show_settings.value)
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
              widget.show_settings.value = !widget.show_settings.value;
              setState(() {});
            },
            video_button_callback: widget.video_button_callback,
            audio_button_callback: widget.audio_button_callback,
            audio_devices: widget.audio_devices,
            video_devices: widget.video_devices,
            current_audio_device: widget.current_audio_device,
            current_video_device: widget.current_video_device,
            current_audio_device_id: widget.current_audio_device_id,
            current_video_device_id: widget.current_video_device_id,
            zoom: widget.zoom,
            local_video_renderer: widget.local_video_renderer,
            mirror_local_renderer: widget.mirror_local_renderer,
          ),
        ),
      if (widget.show_info.value)
        FractionallySizedBox(
          heightFactor: portrait ? 0.7 : 0.5,
          widthFactor: portrait ? 0.9 : 0.5,
          child: RoomInfo(
            background_color: Colors.blueGrey.withValues(alpha: 0.9),
            main_color: widget.main_color,
            room_id: widget.room_id.value,
            call_base_url: widget.call_base_url,
            callback: () {
              widget.show_info.value = !widget.show_info.value;
              setState(() {});
            },
            parent_context: context,
          ),
        ),
    ];
  }
}
