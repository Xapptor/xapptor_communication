import 'package:flutter/material.dart';
import 'custom_dropdown_button.dart';

class Settings extends StatefulWidget {
  Settings({
    required this.background_color,
    required this.audio_dropdown_button,
    required this.video_dropdown_button,
    required this.close_button_callback,
  });

  final Color background_color;
  final CustomDropdownButton audio_dropdown_button;
  final CustomDropdownButton video_dropdown_button;
  final Function close_button_callback;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.background_color,
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
                  widget.close_button_callback();
                },
              ),
            ),
            widget.audio_dropdown_button,
            widget.video_dropdown_button,
          ],
        ),
      ),
    );
  }
}
