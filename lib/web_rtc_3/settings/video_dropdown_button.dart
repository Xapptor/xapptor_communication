import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc_3/settings/custom_dropdown_button.dart';

class VideoDropdownButton extends StatefulWidget {
  final String title;
  final ValueNotifier<List<MediaDeviceInfo>> video_devices;
  final Color? text_color;
  final Function(String new_value) callback;
  final ValueNotifier<String> current_video_device;
  final ValueNotifier<String> current_video_device_id;
  final ValueNotifier<bool> mirror_local_renderer;

  const VideoDropdownButton({
    super.key,
    required this.title,
    required this.video_devices,
    this.text_color = Colors.black,
    required this.callback,
    required this.current_video_device,
    required this.current_video_device_id,
    required this.mirror_local_renderer,
  });

  @override
  State<VideoDropdownButton> createState() => _VideoDropdownButtonState();
}

class _VideoDropdownButtonState extends State<VideoDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return CallSettingsDropdownButton(
      value: widget.current_video_device.value,
      on_changed: (new_value) {
        if (new_value == widget.current_video_device.value) return;

        if (UniversalPlatform.isMobile) {
          if (new_value.toLowerCase().contains("back")) {
            widget.mirror_local_renderer.value = false;
          } else if (new_value.toLowerCase().contains("front")) {
            widget.mirror_local_renderer.value = true;
          }
        }
        widget.callback(new_value);
      },
      items: widget.video_devices.value.map((e) => e.label).toList(),
      title: widget.title,
      text_color: widget.text_color,
    );
  }
}
