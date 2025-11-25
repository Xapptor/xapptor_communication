import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_3/settings/custom_dropdown_button.dart';

class AudioDropdownButton extends StatefulWidget {
  final String title;
  final ValueNotifier<List<MediaDeviceInfo>> audio_devices;
  final Color? text_color;
  final VoidCallback callback;
  final ValueNotifier<String> current_audio_device;
  final ValueNotifier<String> current_audio_device_id;

  const AudioDropdownButton({
    super.key,
    required this.title,
    required this.audio_devices,
    this.text_color = Colors.black,
    required this.callback,
    required this.current_audio_device,
    required this.current_audio_device_id,
  });

  @override
  State<AudioDropdownButton> createState() => _AudioDropdownButtonState();
}

class _AudioDropdownButtonState extends State<AudioDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return CallSettingsDropdownButton(
      value: widget.current_audio_device.value,
      on_changed: (new_value) {
        widget.current_audio_device.value = new_value;
        widget.current_audio_device_id.value =
            widget.audio_devices.value.firstWhere((device) => device.label == new_value).deviceId;

        widget.callback();
      },
      title: widget.title,
      items: widget.audio_devices.value.map((device) => device.label).toList(),
      text_color: widget.text_color,
    );
  }
}
