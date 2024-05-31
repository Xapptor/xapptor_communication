import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/room/create_room.dart';

extension StateExtension on CallViewState {
  create_room_button() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.main_color,
          ),
          onPressed: () async {
            call_create_room();
          },
          child: Text(
            widget.text_list.last,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
