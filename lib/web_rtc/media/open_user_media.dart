// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  Future open_user_media() async {
    String facing_mode = '';
    if (UniversalPlatform.isMobile) {
      facing_mode = current_video_device_id.value.contains("0") ? 'environment' : 'user';
    }

    Map video_json = {
      'mandatory': {
        'deviceId': current_video_device_id.value,
        'minWidth': '640',
        'minHeight': '480',
        'minFrameRate': '30',
      },
    };

    if (facing_mode != '') {
      video_json['facingMode'] = facing_mode;
    }

    MediaStream stream = await navigator.mediaDevices.getUserMedia(
      {
        'audio': {
          'deviceId': current_audio_device_id.value,
        },
        'video': video_json,
      },
    );

    // if (local_renderer.value.srcObject != null) {
    //   local_renderer.value.srcObject!.getTracks().forEach((track) {
    //     track.stop();
    //   });
    // }

    local_renderer.value.srcObject = stream;

    // MARK: - Enable/Disable Video
    List<MediaStreamTrack>? video_tracks = local_renderer.value.srcObject?.getVideoTracks();

    if (video_tracks != null && video_tracks.isNotEmpty) {
      for (var track in video_tracks) {
        track.enabled = enable_video.value;
      }
    }

    // MARK: - Enable/Disable Audio
    List<MediaStreamTrack>? audio_tracks = local_renderer.value.srcObject?.getAudioTracks();

    if (audio_tracks != null && audio_tracks.isNotEmpty) {
      local_renderer.value.muted = !enable_audio.value;

      for (var track in audio_tracks) {
        track.enabled = enable_audio.value;
      }
    }
    setState(() {});
  }
}
