import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

class JoinAnotherRoomContainer extends StatelessWidget {
  JoinAnotherRoomContainer({super.key, 
    required this.text_list,
    required this.local_renderer,
    required this.show_qr_scanner,
    required this.setState,
    required this.main_color,
    required this.join_room,
    required this.room_id_controller,
  });

  final List<String> text_list;
  RTCVideoRenderer local_renderer;
  final ValueNotifier<bool> show_qr_scanner;
  final Function setState;
  final Color main_color;
  final Function join_room;
  final TextEditingController room_id_controller;

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: Row(
            children: [
              Text(
                text_list[text_list.length - 4],
                textAlign: TextAlign.left,
              ),
              UniversalPlatform.isWeb
                  ? Container()
                  : IconButton(
                      onPressed: () {
                        local_renderer.srcObject
                            ?.getVideoTracks()
                            .forEach((element) {
                          element.stop();
                        });

                        show_qr_scanner.value = true;
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: main_color,
                      ),
                    ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              width: screen_width * (portrait ? 0.5 : 0.15),
              child: TextFormField(
                controller: room_id_controller,
                decoration: InputDecoration(
                  hintText: text_list[text_list.length - 3],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: main_color,
              ),
              onPressed: () async {
                if (room_id_controller.text.isNotEmpty) {
                  join_room();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You need to enter the room ID',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                text_list[text_list.length - 2],
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
