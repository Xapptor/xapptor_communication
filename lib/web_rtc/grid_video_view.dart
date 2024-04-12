import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_communication/web_rtc/video_view_container.dart';
import 'package:xapptor_logic/get_random_color.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

class GridVideoView extends StatefulWidget {
  final ValueNotifier<RTCVideoRenderer> local_renderer;
  final ValueNotifier<List<RemoteRenderer>> remote_renderers;
  final bool mirror_local_renderer;
  final String user_name;
  final String user_id;
  final ValueNotifier<Room>? room;
  final ValueNotifier<bool> enable_video;

  const GridVideoView({
    super.key,
    required this.local_renderer,
    required this.remote_renderers,
    required this.mirror_local_renderer,
    required this.user_name,
    required this.user_id,
    required this.room,
    required this.enable_video,
  });

  @override
  State<GridVideoView> createState() => _GridVideoViewState();
}

class _GridVideoViewState extends State<GridVideoView> {
  List<Color> random_colors = [Colors.lightBlueAccent];

  @override
  void initState() {
    for (int i = 0; i < 10; i++) {
      random_colors.add(
        get_random_color(
          seed_color: null,
        ).withOpacity(1),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<RemoteRenderer> remote_renderers = widget.remote_renderers.value;

    bool portrait = is_portrait(context);
    int cross_axis_count = remote_renderers.isEmpty
        ? 1
        : portrait
            ? 1
            : 2;

    if (remote_renderers.length == 2) {
      cross_axis_count = 2;
    } else if (remote_renderers.length > 2 && remote_renderers.length <= 4) {
      cross_axis_count = 2;
    } else if (remote_renderers.length > 4 && remote_renderers.length <= 6) {
      cross_axis_count = 3;
    } else if (remote_renderers.length > 6) {
      cross_axis_count = 4;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross_axis_count,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: remote_renderers.length + 1,
        itemBuilder: (context, index) {
          late Widget video_view;
          late String user_name;
          late String user_id;
          bool user_is_local = true;
          bool is_the_same_account = false;

          if (index == 0) {
            video_view = RTCVideoView(
              widget.local_renderer.value,
              mirror: widget.mirror_local_renderer,
            );

            user_name = widget.user_name;
            user_id = widget.user_id;
          } else {
            RemoteRenderer remote_renderer = remote_renderers[index - 1];

            video_view = RTCVideoView(
              remote_renderer.video_renderer,
              mirror: false,
            );

            user_name = remote_renderer.user_name;
            user_id = remote_renderer.user_id;

            user_is_local = false;
            is_the_same_account = user_id == widget.user_id;
          }
          return VideoViewContainer(
            background_color: random_colors[index],
            user_name: user_name,
            user_is_local: user_is_local,
            is_the_same_account: is_the_same_account,
            room: widget.room,
            child: widget.enable_video.value || !user_is_local
                ? video_view
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        size: 100,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Video off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
