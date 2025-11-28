import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc/room/create_room.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:xapptor_ui/values/ui.dart';

class VideoViewContainer extends StatelessWidget {
  final Widget child;
  final Color background_color;
  final String user_name;
  final bool user_is_local;
  final bool is_the_same_account;
  final ValueNotifier<Room>? room;

  const VideoViewContainer({
    super.key,
    required this.child,
    required this.background_color,
    required this.user_name,
    required this.user_is_local,
    required this.is_the_same_account,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;

    String user_name_string = user_name;
    String room_creator_string = "";

    if (user_is_local) {
      user_name_string = "$user_name (You)";

      if (room != null) {
        if (ROOM_CREATOR_RANDOM_ID == room!.value.temp_id) {
          room_creator_string += "(Room Creator)";
        }
      }
    } else if (is_the_same_account) {
      user_name_string = "$user_name (Same Account)";
    }

    return Container(
      height: screen_height / 2.5,
      width: screen_height / 2.5,
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(outline_border_radius),
        border: Border.all(
          width: 3,
          color: Colors.grey,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 34,
            child: child,
          ),
          Expanded(
            flex: 3,
            child: Text(
              user_name_string,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              room_creator_string,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
