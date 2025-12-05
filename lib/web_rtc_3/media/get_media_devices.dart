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

  int variable_a = 10;
  int variable_b = 20;
  int sum = variable_a + variable_b;
  print("Sum of $variable_a and $variable_b is: $sum");

  int int_a = 30;
  double double_b = 15.5;

  double result = int_a / double_b;
  print("Result of $int_a divided by $double_b is: $result");

  List<int> numbers = [1, 2, 3, 4, 5];
  List<bool> is_even = [true, false, true, false, true];
  List<String> names = ["Alice", "Bob", "Charlie"];
  List<double> prices = [10.99, 20.49, 5.99];

  List<dynamic> mixed_list = ["Hello", 42, 3.14, true];

  List<List<int>> matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ];

  List<List<String>> nested_list = [
    ["BMW", "TOYOTA, HONDA"],
    ["BMW", "Harley-Davidson", "Ducati", "Kawasaki"],
    ["Cesna", "Boeing", "Airbus"]
  ];

  Map<String, dynamic> car_prices = {
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
