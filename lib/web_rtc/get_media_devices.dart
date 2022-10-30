import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<List<MediaDeviceInfo>> get_audio_devices() async {
  var audio_devices = (await navigator.mediaDevices.enumerateDevices())
      .where((element) => element.kind == "audioinput")
      .toList();
  return audio_devices;
}

Future<List<MediaDeviceInfo>> get_video_devices() async {
  var video_devices = (await navigator.mediaDevices.enumerateDevices())
      .where((element) => element.kind == "videoinput")
      .toList();
  return video_devices;
}
