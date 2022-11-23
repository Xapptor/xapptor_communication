import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/remote_renderer.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'dart:math' as math;

class GridVideoView extends StatelessWidget {
  const GridVideoView({
    required this.local_renderer,
    required this.remote_renderers,
  });

  final RTCVideoRenderer local_renderer;
  final List<RemoteRenderer> remote_renderers;

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

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
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross_axis_count,
          childAspectRatio: 1.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: remote_renderers.length + 1,
        itemBuilder: (context, index) {
          Color random_color =
              Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0);

          late Widget video_view;

          if (index == 0) {
            video_view = RTCVideoView(
              local_renderer,
              mirror: true,
            );
          } else {
            RTCVideoRenderer remote_renderer =
                remote_renderers[index - 1].video_renderer;

            video_view = RTCVideoView(
              remote_renderer,
              mirror: true,
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: random_color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 3,
                color: Colors.blueGrey,
              ),
            ),
            child: video_view,
          );
        },
      ),
    );
  }
}
