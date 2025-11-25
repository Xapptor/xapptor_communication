import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.enable_audio.value ? Icons.mic : Icons.mic_off,
            color: widget.main_color,
          ),
          onPressed: () {
            widget.enable_audio.value = !widget.enable_audio.value;
            open_user_media();
          },
        ),
        IconButton(
          icon: Icon(
            widget.enable_video.value ? Icons.videocam : Icons.videocam_off,
            color: widget.main_color,
          ),
          onPressed: () {
            widget.enable_video.value = !widget.enable_video.value;
            open_user_media();
          },
        ),
        // Settings icon button
        IconButton(
          icon: Icon(
            Icons.settings,
            color: widget.main_color,
          ),
          onPressed: () {
            widget.show_settings.value = !widget.show_settings.value;
            setState(() {});
          },
        ),
        if (widget.in_a_call.value)
          IconButton(
            icon: Icon(
              Icons.info,
              color: widget.main_color,
            ),
            onPressed: () {
              widget.show_info.value = !widget.show_info.value;
              setState(() {});
            },
          ),
        if (widget.in_a_call.value)
          IconButton(
            icon: Icon(
              widget.share_screen.value ? Icons.stop_screen_share_outlined : Icons.screen_share_outlined,
              color: widget.share_screen.value ? Colors.red : widget.main_color,
            ),
            tooltip: widget.share_screen.value ? "Stop Screen Sharing" : "Init Screen Sharing",
            onPressed: () async {
              widget.share_screen.value = !widget.share_screen.value;
              widget.mirror_local_renderer.value = !widget.share_screen.value;

              if (widget.share_screen.value) {
                final media_constraints = <String, dynamic>{
                  'audio': true,
                  'video': true,
                };
                var stream = await navigator.mediaDevices.getDisplayMedia(media_constraints);
                widget.local_video_renderer.srcObject = stream;
              } else {
                stop_screen_share_function();
              }
              setState(() {});
            },
          ),
      ],
    );
  }
}
