import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';

Future open_user_media({
  required ValueNotifier<String> current_video_device_id,
  required ValueNotifier<String> current_audio_device_id,
  required ValueNotifier<bool> enable_video,
  required ValueNotifier<bool> enable_audio,
  required RTCVideoRenderer local_video_renderer,
}) async {
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

  local_video_renderer.srcObject = stream;

  // MARK: - Enable/Disable Video
  List<MediaStreamTrack>? video_tracks = local_video_renderer.srcObject?.getVideoTracks();

  if (video_tracks != null && video_tracks.isNotEmpty) {
    for (var track in video_tracks) {
      track.enabled = enable_video.value;
    }
  }

  // MARK: - Enable/Disable Audio
  List<MediaStreamTrack>? audio_tracks = local_video_renderer.srcObject?.getAudioTracks();

  if (audio_tracks != null && audio_tracks.isNotEmpty) {
    local_video_renderer.muted = !enable_audio.value;

    for (var track in audio_tracks) {
      track.enabled = enable_audio.value;
    }
  }
  //setState(() {});
}
