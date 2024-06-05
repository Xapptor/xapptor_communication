import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/screen_select_dialog.dart';

extension SignalingExtension on Signaling {
  Future<MediaStream> create_stream(
    String media,
    bool user_screen, {
    BuildContext? context,
  }) async {
    final Map<String, dynamic> media_constraints = {
      'audio': user_screen ? false : true,
      'video': user_screen
          ? true
          : {
              'mandatory': {
                'minWidth': '640', // Provide your own width, height and frame rate here
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
    };
    late MediaStream stream;
    if (user_screen) {
      if (WebRTC.platformIsDesktop) {
        final source = await showDialog<DesktopCapturerSource>(
          context: context!,
          builder: (context) => ScreenSelectDialog(),
        );
        stream = await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
          'video': source == null
              ? true
              : {
                  'deviceId': {'exact': source.id},
                  'mandatory': {'frameRate': 30.0}
                }
        });
      } else {
        stream = await navigator.mediaDevices.getDisplayMedia(media_constraints);
      }
    } else {
      stream = await navigator.mediaDevices.getUserMedia(media_constraints);
    }

    on_local_stream?.call(stream);
    return stream;
  }
}
