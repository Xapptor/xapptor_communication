// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/media/open_user_media.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  settings_icons({
    required Function stop_screen_share_function,
  }) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            enable_audio.value ? Icons.mic : Icons.mic_off,
            color: widget.main_color,
          ),
          onPressed: () {
            enable_audio.value = !enable_audio.value;
            open_user_media();
          },
        ),
        IconButton(
          icon: Icon(
            enable_video.value ? Icons.videocam : Icons.videocam_off,
            color: widget.main_color,
          ),
          onPressed: () {
            enable_video.value = !enable_video.value;
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
            show_settings.value = !show_settings.value;
            setState(() {});
          },
        ),

        in_a_call.value
            ? IconButton(
                icon: Icon(
                  Icons.info,
                  color: widget.main_color,
                ),
                onPressed: () {
                  show_info.value = !show_info.value;
                  setState(() {});
                },
              )
            : Container(),
        in_a_call.value
            ? IconButton(
                icon: Icon(
                  share_screen.value ? Icons.stop_screen_share_outlined : Icons.screen_share_outlined,
                  color: share_screen.value ? Colors.red : widget.main_color,
                ),
                tooltip: share_screen.value ? "Stop Screen Sharing" : "Init Screen Sharing",
                onPressed: () async {
                  share_screen.value = !share_screen.value;
                  mirror_local_renderer.value = !share_screen.value;

                  if (share_screen.value) {
                    final media_constraints = <String, dynamic>{
                      'audio': true,
                      'video': true,
                    };
                    var stream = await navigator.mediaDevices.getDisplayMedia(media_constraints);
                    local_renderer.value.srcObject = stream;
                  } else {
                    stop_screen_share_function();
                  }
                  setState(() {});
                },
              )
            : Container(),
      ],
    );
  }
}
