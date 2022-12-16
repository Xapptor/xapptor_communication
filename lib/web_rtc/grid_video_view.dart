import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc/model/remote_renderer.dart';
import 'package:xapptor_logic/get_random_color.dart';

class GridVideoView extends StatefulWidget {
  final RTCVideoRenderer local_renderer;
  final List<RemoteRenderer> remote_renderers;
  final bool mirror_local_renderer;
  final String user_name;

  const GridVideoView({
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
    int cross_axis_count = 1;
    if (widget.remote_renderers.length == 2) {
      cross_axis_count = 2;
    } else if (widget.remote_renderers.length <= 4) {
      cross_axis_count = 2;
    } else if (widget.remote_renderers.length <= 6) {
      cross_axis_count = 3;
    } else if (widget.remote_renderers.length > 6) {
      cross_axis_count = 4;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: widget.remote_renderers.length > 0
          ? GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross_axis_count,
                childAspectRatio: 1.0,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: widget.remote_renderers.length + 1,
              itemBuilder: (context, index) {
                print("Color: ${random_colors[index]}");
                late Widget video_view;
                late String user_name;

                if (index == 0) {
                  video_view = RTCVideoView(
                    widget.local_renderer,
                    mirror: widget.mirror_local_renderer,
                  );
                  user_name = widget.user_name;
                } else {
                  RemoteRenderer remote_renderer =
                      widget.remote_renderers[index - 1];

                  video_view = RTCVideoView(
                    remote_renderer.video_renderer,
                    mirror: widget.mirror_local_renderer,
                  );
                  user_name = remote_renderer.user_name;
                }
                return VideoViewContainer(
                  child: video_view,
                  background_color: random_colors[index],
                  user_name: user_name,
                );
              },
            )
          : VideoViewContainer(
              child: RTCVideoView(
                widget.local_renderer,
                mirror: widget.mirror_local_renderer,
              ),
              background_color: random_colors.first,
              user_name: widget.user_name,
            ),
    );
  }
}

class VideoViewContainer extends StatelessWidget {
  final Widget child;
  final Color background_color;
  final String user_name;

  const VideoViewContainer({
    required this.child,
    required this.background_color,
    required this.user_name,
  });

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;

    return Container(
      height: screen_height / 2.5,
      width: screen_height / 2.5,
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 3,
          color: Colors.grey,
        ),
      ),
      child: Column(
        children: [
          Spacer(flex: 1),
          Expanded(
            flex: 40,
            child: child,
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 4,
            child: Text(
              user_name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}
