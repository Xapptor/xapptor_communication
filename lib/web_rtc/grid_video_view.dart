import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_communication/web_rtc/video_view_container.dart';
import 'package:xapptor_logic/get_random_color.dart';

class GridVideoView extends StatefulWidget {
  final RTCVideoRenderer local_renderer;
  final ValueNotifier<List<RemoteRenderer>> remote_renderers;
  final bool mirror_local_renderer;
  final String user_name;

  const GridVideoView({
    super.key,
    required this.local_renderer,
    required this.remote_renderers,
    required this.mirror_local_renderer,
    required this.user_name,
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

    int cross_axis_count = 1;
    if (remote_renderers.length == 2) {
      cross_axis_count = 2;
    } else if (remote_renderers.length <= 4) {
      cross_axis_count = 2;
    } else if (remote_renderers.length <= 6) {
      cross_axis_count = 3;
    } else if (remote_renderers.length > 6) {
      cross_axis_count = 4;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: remote_renderers.isNotEmpty
          ? GridView.builder(
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

                if (index == 0) {
                  video_view = RTCVideoView(
                    widget.local_renderer,
                    mirror: widget.mirror_local_renderer,
                  );
                  user_name = widget.user_name;
                } else {
                  RemoteRenderer remote_renderer = remote_renderers[index - 1];

                  video_view = RTCVideoView(
                    remote_renderer.video_renderer,
                    mirror: widget.mirror_local_renderer,
                  );
                  user_name = remote_renderer.user_name;
                }
                return VideoViewContainer(
                  background_color: random_colors[index],
                  user_name: user_name,
                  user_is_local: false,
                  child: video_view,
                );
              },
            )
          : VideoViewContainer(
              background_color: random_colors.first,
              user_name: widget.user_name,
              user_is_local: true,
              child: RTCVideoView(
                widget.local_renderer,
                mirror: widget.mirror_local_renderer,
              ),
            ),
    );
  }
}
