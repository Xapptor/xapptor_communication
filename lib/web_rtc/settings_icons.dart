import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SettingsIcons extends StatelessWidget {
  SettingsIcons({
    required this.main_color,
    required this.enable_audio,
    required this.enable_video,
    required this.local_renderer,
    required this.show_settings,
    required this.show_info,
    required this.call_open_user_media,
    required this.setState,
    required this.in_a_call,
  });

  final Color main_color;
  final ValueNotifier<bool> enable_audio;
  final ValueNotifier<bool> enable_video;
  RTCVideoRenderer local_renderer;
  final ValueNotifier<bool> show_settings;
  final ValueNotifier<bool> show_info;
  final Function call_open_user_media;
  final Function setState;
  final ValueNotifier<bool> in_a_call;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              enable_audio.value ? Icons.mic : Icons.mic_off,
              color: main_color,
            ),
            onPressed: () {
              enable_audio.value = !enable_audio.value;
              local_renderer.muted = !enable_audio.value;

              call_open_user_media();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              enable_video.value ? Icons.videocam : Icons.videocam_off,
              color: main_color,
            ),
            onPressed: () {
              enable_video.value = !enable_video.value;

              if (local_renderer.srcObject != null) {
                if (local_renderer.srcObject!.getVideoTracks().length > 0) {
                  local_renderer.srcObject?.getVideoTracks()[0].enabled =
                      enable_video.value;
                } else {
                  call_open_user_media();
                }
              } else {
                call_open_user_media();
              }
              setState(() {});
            },
          ),
          // Settings icon button
          IconButton(
            icon: Icon(
              Icons.settings,
              color: main_color,
            ),
            onPressed: () {
              show_settings.value = !show_settings.value;
              setState(() {});
            },
          ),
          in_a_call.value
              ? IconButton(
                  icon: Icon(
                    Icons.info,
                    color: main_color,
                  ),
                  onPressed: () {
                    show_info.value = !show_info.value;
                    setState(() {});
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
