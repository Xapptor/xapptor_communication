import 'package:flutter/material.dart';
import 'custom_dropdown_button.dart';

class SettingsMenu extends StatelessWidget {
  SettingsMenu({
    required this.background_color,
    required this.audio_dropdown_button,
    required this.video_dropdown_button,
    required this.callback,
  });

  final Color background_color;
  final CustomDropdownButton audio_dropdown_button;
  final CustomDropdownButton video_dropdown_button;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.95,
        widthFactor: 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  callback();
                },
              ),
            ),
            audio_dropdown_button,
            video_dropdown_button,
          ],
        ),
      ),
    );
  }
}
