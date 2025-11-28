import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc_3/settings/audio_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc_3/settings/video_dropdown_button.dart';
import 'package:xapptor_communication/web_rtc_3/settings/zoom_slider.dart';
import 'package:xapptor_ui/values/ui.dart';

class SettingsMenu extends StatefulWidget {
  final Color background_color;
  final VoidCallback close_callback;
  final Function(String new_value) video_button_callback;
  final VoidCallback audio_button_callback;
  final ValueNotifier<List<MediaDeviceInfo>> audio_devices;
  final ValueNotifier<List<MediaDeviceInfo>> video_devices;
  final ValueNotifier<String> current_audio_device;
  final ValueNotifier<String> current_video_device;
  final ValueNotifier<String> current_audio_device_id;
  final ValueNotifier<String> current_video_device_id;
  final ValueNotifier<double> zoom;
  final RTCVideoRenderer local_video_renderer;
  final ValueNotifier<bool> mirror_local_renderer;

  const SettingsMenu({
    super.key,
    required this.background_color,
    required this.close_callback,
    required this.video_button_callback,
    required this.audio_button_callback,
    required this.audio_devices,
    required this.video_devices,
    required this.current_audio_device,
    required this.current_video_device,
    required this.current_audio_device_id,
    required this.current_video_device_id,
    required this.zoom,
    required this.local_video_renderer,
    required this.mirror_local_renderer,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: widget.background_color,
        borderRadius: BorderRadius.circular(outline_border_radius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                flex: 8,
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: widget.close_callback,
                ),
              ),
            ],
          ),
          AudioDropdownButton(
            title: "Audio Input",
            audio_devices: widget.audio_devices,
            text_color: Colors.white,
            callback: widget.audio_button_callback,
            current_audio_device: widget.current_audio_device,
            current_audio_device_id: widget.current_audio_device_id,
          ),
          VideoDropdownButton(
            title: "Video Input",
            video_devices: widget.video_devices,
            text_color: Colors.white,
            callback: widget.video_button_callback,
            current_video_device: widget.current_video_device,
            current_video_device_id: widget.current_video_device_id,
            mirror_local_renderer: widget.mirror_local_renderer,
          ),
          if (UniversalPlatform.isMobile)
            zoom_slider(
              zoom: widget.zoom,
              local_video_renderer: widget.local_video_renderer,
            ),
        ],
      ),
    );
  }
}
