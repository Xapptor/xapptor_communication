import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';

extension StateExtension on Signaling {
  Future open_user_media({
    required RTCVideoRenderer local_renderer,
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

    local_renderer.srcObject = stream;
    local_stream = stream;

    if (local_renderer.srcObject!.getVideoTracks().isNotEmpty) {
      local_renderer.srcObject!.getVideoTracks()[0].enabled = enable_video;
    }

    List<MediaStreamTrack>? audio_tracks = local_stream?.getAudioTracks();

    if (audio_tracks != null && audio_tracks.isNotEmpty) {
      local_renderer.muted = !enable_audio;
      audio_tracks.first.enabled = enable_audio;
    }
    setState(() {});
  }
}
