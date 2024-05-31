// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/room/room_info.dart';
import 'package:xapptor_communication/web_rtc/settings/settings_menu.dart';

extension StateExtension on CallViewState {
  List<Widget> floating_menus({
    required bool portrait,
  }) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return [
      show_settings.value
          ? Container(
              constraints: BoxConstraints(
                minHeight: height * 0.2,
                minWidth: width * 0.2,
                maxHeight: height * 0.45,
                maxWidth: width * 0.8,
              ),
              child: settings_menu(
                background_color: Colors.blueGrey.withOpacity(0.95),
              ),
            )
          : Container(),
      show_info.value
          ? FractionallySizedBox(
              heightFactor: portrait ? 0.7 : 0.5,
              widthFactor: portrait ? 0.9 : 0.5,
              child: RoomInfo(
                background_color: Colors.blueGrey.withOpacity(0.9),
                main_color: widget.main_color,
                room_id: widget.room_id.value,
                call_base_url: widget.call_base_url,
                callback: () {
                  show_info.value = !show_info.value;
                  setState(() {});
                },
                parent_context: context,
              ),
            )
          : Container(),
    ];
  }
}
