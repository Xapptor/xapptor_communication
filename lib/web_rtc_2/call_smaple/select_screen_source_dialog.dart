import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog.dart';

Future<void> select_screen_source_dialog({
  required BuildContext context,
  required Function switch_to_screen_sharing,
}) async {
  MediaStream? screen_stream;
  if (WebRTC.platformIsDesktop) {
    final source = await showDialog<DesktopCapturerSource>(
      context: context,
      builder: (context) => ScreenSelectDialog(),
    );
    if (source != null) {
      try {
        var stream = await navigator.mediaDevices.getDisplayMedia(
          <String, dynamic>{
            'video': {
              'deviceId': {'exact': source.id},
              'mandatory': {'frameRate': 30.0}
            }
          },
        );
        stream.getVideoTracks()[0].onEnded = () {
          debugPrint('By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
        };
        screen_stream = stream;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  } else if (WebRTC.platformIsWeb) {
    screen_stream = await navigator.mediaDevices.getDisplayMedia(
      <String, dynamic>{
        'audio': false,
        'video': true,
      },
    );
  }
  if (screen_stream != null) switch_to_screen_sharing(screen_stream);
}
