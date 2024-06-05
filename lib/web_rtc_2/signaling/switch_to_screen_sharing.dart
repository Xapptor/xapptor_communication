import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  switch_to_screen_sharing(MediaStream stream) {
    if (local_stream != null && video_source != VideoSource.screen) {
      for (var sender in senders) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      }
      on_local_stream?.call(stream);
      video_source = VideoSource.screen;
    }
  }
}
