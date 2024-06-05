import 'package:flutter/material.dart';

Widget? floating_action_button({
  required BuildContext context,
  required Function switch_camera,
  required Function select_screen_source_dialog,
  required Function hang_up,
  required bool in_calling,
  required Function mute_mic,
}) {
  return in_calling
      ? SizedBox(
          width: 240.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                tooltip: 'Camera',
                onPressed: () => switch_camera,
                child: const Icon(Icons.switch_camera),
              ),
              FloatingActionButton(
                tooltip: 'Screen Sharing',
                onPressed: () => select_screen_source_dialog(context),
                child: const Icon(Icons.desktop_mac),
              ),
              FloatingActionButton(
                onPressed: () => hang_up,
                tooltip: 'Hangup',
                backgroundColor: Colors.pink,
                child: const Icon(Icons.call_end),
              ),
              FloatingActionButton(
                tooltip: 'Mute Mic',
                onPressed: () => mute_mic,
                child: const Icon(Icons.mic_off),
              )
            ],
          ),
        )
      : null;
}
