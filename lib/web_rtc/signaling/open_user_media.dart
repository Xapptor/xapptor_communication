import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc/signaling/signaling.dart';

extension StateExtension on Signaling {
  Future open_user_media({
    required RTCVideoRenderer local_renderer,
    required RTCVideoRenderer? remote_renderer,
    required String audio_device_id,
    required String video_device_id,
    required bool enable_audio,
    required bool enable_video,
  }) async {
    if (enable_audio || enable_video) {
      String facing_mode = '';
      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
        facing_mode = video_device_id == "0" ? 'environment' : 'user';
      }

      Map video_json = {
        'deviceId': video_device_id,
      };

      if (facing_mode != '') {
        video_json['facingMode'] = facing_mode;
      }

      var stream = await navigator.mediaDevices.getUserMedia(
        {
          'audio': enable_audio
              ? {
                  'deviceId': audio_device_id,
                }
              : false,
          'video': enable_video ? video_json : false,
        },
      );

      local_renderer.srcObject = stream;
      local_stream = stream;

      remote_renderer?.srcObject = await createLocalMediaStream('key');
      local_renderer.muted = !enable_audio;
    }
  }
}
