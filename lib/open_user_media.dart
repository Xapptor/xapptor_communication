import 'package:flutter_webrtc/flutter_webrtc.dart';

Future open_user_media({
  required RTCVideoRenderer local_video,
  required RTCVideoRenderer remote_video,
  required MediaStream? local_stream,
}) async {
  var stream = await navigator.mediaDevices.getUserMedia(
    {
      'audio': false,
      'video': {
        'facingMode': 'user',
      }
    },
  );

  local_video.srcObject = stream;
  local_stream = stream;

  remote_video.srcObject = await createLocalMediaStream('key');
}
