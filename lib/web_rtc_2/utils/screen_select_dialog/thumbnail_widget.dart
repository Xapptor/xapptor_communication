import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ThumbnailWidget extends StatefulWidget {
  final DesktopCapturerSource source;
  final bool selected;
  final Function(DesktopCapturerSource) on_tap;

  const ThumbnailWidget({
    super.key,
    required this.source,
    required this.selected,
    required this.on_tap,
  });

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.add(widget.source.onThumbnailChanged.stream.listen((event) {
      setState(() {});
    }));
    _subscriptions.add(widget.source.onNameChanged.stream.listen((event) {
      setState(() {});
    }));
  }

  @override
  void deactivate() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: widget.selected
                ? BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.blueAccent,
                    ),
                  )
                : null,
            child: InkWell(
              onTap: () {
                debugPrint('Selected source id => ${widget.source.id}');
                widget.on_tap(widget.source);
              },
              child: widget.source.thumbnail != null
                  ? Image.memory(
                      widget.source.thumbnail!,
                      gaplessPlayback: true,
                      alignment: Alignment.center,
                    )
                  : Container(),
            ),
          ),
        ),
        Text(
          widget.source.name,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
