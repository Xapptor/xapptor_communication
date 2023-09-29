import 'package:flutter/material.dart';
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

Future get_media_devices({
  required ValueNotifier<List<MediaDeviceInfo>> audio_devices,
  required ValueNotifier<List<MediaDeviceInfo>> video_devices,
  required ValueNotifier<String> current_audio_device,
  required ValueNotifier<String> current_audio_device_id,
  required ValueNotifier<String> current_video_device,
  required ValueNotifier<String> current_video_device_id,
  required Function callback,
}) async {
  audio_devices.value = await get_audio_devices();
  video_devices.value = await get_video_devices();

  if (audio_devices.value.isNotEmpty) {
    current_audio_device.value = audio_devices.value[0].label;
    current_audio_device_id.value = audio_devices.value[0].deviceId;
  }
  if (video_devices.value.isNotEmpty) {
    current_video_device.value = video_devices.value[0].label;
    current_video_device_id.value = video_devices.value[0].deviceId;
  }
  callback();
}
