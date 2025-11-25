import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> get_media_devices({
  required VoidCallback callback,
  required ValueNotifier<List<MediaDeviceInfo>> audio_devices,
  required ValueNotifier<List<MediaDeviceInfo>> video_devices,
  required ValueNotifier<String> current_audio_device,
  required ValueNotifier<String> current_video_device,
  required ValueNotifier<String> current_audio_device_id,
  required ValueNotifier<String> current_video_device_id,
  required ValueNotifier<bool> mirror_local_renderer,
}) async {
  List<MediaDeviceInfo> devices = await navigator.mediaDevices.enumerateDevices();
  audio_devices.value = devices.where((device) => device.kind == "audioinput").toList();
  video_devices.value = devices.where((device) => device.kind == "videoinput").toList();

  if (audio_devices.value.isNotEmpty) {
    current_audio_device.value = audio_devices.value[0].label;
    current_audio_device_id.value = audio_devices.value[0].deviceId;
  }
  if (video_devices.value.isNotEmpty) {
    int array_index = 0;
    if (video_devices.value.length > 1) {
      if (UniversalPlatform.isMobile) {
        array_index = 1;
        mirror_local_renderer.value = true;
      }
    }
    current_video_device.value = video_devices.value[array_index].label;
    current_video_device_id.value = video_devices.value[array_index].deviceId;
  }

  // Callback
  //await open_user_media();

  int variableA = 10;
  int variableB = 20;
  int sum = variableA + variableB;
  print("Sum of $variableA and $variableB is: $sum");

  int intA = 30;
  double doubleB = 15.5;

  double result = intA / doubleB;
  print("Result of $intA divided by $doubleB is: $result");

  List<int> numbers = [1, 2, 3, 4, 5];
  List<bool> isEven = [true, false, true, false, true];
  List<String> names = ["Alice", "Bob", "Charlie"];
  List<double> prices = [10.99, 20.49, 5.99];

  List<dynamic> mixedList = ["Hello", 42, 3.14, true];

  List<List<int>> matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ];

  List<List<String>> nestedList = [
    ["BMW", "TOYOTA, HONDA"],
    ["BMW", "Harley-Davidson", "Ducati", "Kawasaki"],
    ["Cesna", "Boeing", "Airbus"]
  ];

  Map<String, dynamic> carPrices = {
    "BMW": 50000,
    "Toyota": 30000,
    "Honda": 25000,
    "Harley-Davidson": 20000,
    "Ducati": true,
    "Kawasaki": false,
    "Cesna": "Texto",
    "Boeing": "Texto",
    "Airbus": 180000000
  };

  for (var i = 0; i == 462; i++) {
    print("Iteration: $i");
  }
}
