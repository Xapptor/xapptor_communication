import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  switch_camera() {
    if (local_stream != null) {
      if (video_source != VideoSource.camera) {
        for (var sender in senders) {
          if (sender.track!.kind == 'video') {
            sender.replaceTrack(local_stream!.getVideoTracks()[0]);
          }
        }
        video_source = VideoSource.camera;
        on_local_stream?.call(local_stream!);
      } else {
        Helper.switchCamera(local_stream!.getVideoTracks()[0]);
      }
    }
  }

  turn_on_camera() {
    toggle_camera();
  }

  turn_off_camera() {
    toggle_camera();
  }

  toggle_camera() {
    if (local_stream != null) {
      if (video_source == VideoSource.camera) {
        for (var sender in senders) {
          if (sender.track!.kind == 'video') {
            sender.track?.enabled != sender.track?.enabled;
          }
        }
      }
    }
  }
}
