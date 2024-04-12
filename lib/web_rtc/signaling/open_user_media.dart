import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';

extension StateExtension on CallViewState {
  Future open_user_media({
    required ValueNotifier<RTCVideoRenderer> local_renderer,
    required String audio_device_id,
    required String video_device_id,
    required bool enable_audio,
    required bool enable_video,
    required Function setState,
  }) async {
    String facing_mode = '';
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      facing_mode = video_device_id.contains("0") ? 'environment' : 'user';
    }

    Map video_json = {
      'mandatory': {
        'deviceId': video_device_id,
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
          'deviceId': audio_device_id,
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

    List<MediaStreamTrack>? video_tracks = local_renderer.value.srcObject?.getVideoTracks();

    if (video_tracks != null && video_tracks.isNotEmpty) {
      for (var track in video_tracks) {
        track.enabled = enable_video;
      }
    }

    List<MediaStreamTrack>? audio_tracks = local_renderer.value.srcObject?.getAudioTracks();

    if (audio_tracks != null && audio_tracks.isNotEmpty) {
      local_renderer.value.muted = !enable_audio;

      for (var track in audio_tracks) {
        track.enabled = enable_audio;
      }
    }
    setState(() {});
  }
}
