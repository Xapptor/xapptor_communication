import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/room_info_container.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'signaling.dart';

class CallView extends StatefulWidget {
  CallView({
    required this.main_color,
    required this.background_color,
    required this.signaling,
    required this.local_renderer,
    required this.remote_renderer,
    required this.enable_audio,
    required this.enable_video,
    required this.text_list,
    required this.room_id,
    required this.was_created,
    required this.call_base_url,
  });

  final Color main_color;
  final Color background_color;
  final Signaling signaling;
  final RTCVideoRenderer local_renderer;
  final RTCVideoRenderer remote_renderer;
  bool enable_audio = false;
  bool enable_video = false;
  final List<String> text_list;
  final String room_id;
  final bool was_created;
  final String call_base_url;

  @override
  _CallViewState createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  @override
  void initState() {
    super.initState();
    if (!widget.was_created) {
      widget.signaling.join_room(widget.room_id, widget.remote_renderer);
    }
  }

  @override
  void dispose() {
    widget.local_renderer.dispose();
    widget.remote_renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return Container(
      color: widget.background_color,
      child: SingleChildScrollView(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Column(
              children: [
                SizedBox(height: sized_box_space),
                Container(
                  height: screen_height * 0.6,
                  child: Flex(
                    direction: portrait ? Axis.vertical : Axis.horizontal,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: RTCVideoView(
                                widget.local_renderer,
                                mirror: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: RTCVideoView(
                                widget.remote_renderer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RoomInfoContainer(
                  main_color: widget.main_color,
                  room_id: widget.room_id,
                  call_base_url: widget.call_base_url,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    child: Icon(Icons.call_end),
                    backgroundColor: Colors.red,
                    onPressed: () {
                      widget.signaling
                          .hang_up(widget.local_renderer)
                          .then((value) {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
                SizedBox(height: sized_box_space),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
