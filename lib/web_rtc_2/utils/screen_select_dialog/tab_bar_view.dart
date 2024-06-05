import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/screen_select_dialog.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/thumbnail_widget.dart';

extension CallSampleStateExtension on ScreenSelectDialog {
  Widget tab_bar_view({
    required setState,
  }) {
    return TabBarView(
      children: [
        Align(
          alignment: Alignment.center,
          child: GridView.count(
            crossAxisSpacing: 8,
            crossAxisCount: 2,
            children: sources.entries
                .where((element) => element.value.type == SourceType.Screen)
                .map(
                  (e) => ThumbnailWidget(
                    on_tap: (source) {
                      setState(() {
                        selected_source = source;
                      });
                    },
                    source: e.value,
                    selected: selected_source?.id == e.value.id,
                  ),
                )
                .toList(),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: GridView.count(
            crossAxisSpacing: 8,
            crossAxisCount: 3,
            children: sources.entries
                .where((source) => source.value.type == SourceType.Window)
                .map(
                  (e) => ThumbnailWidget(
                    on_tap: (source) {
                      setState(
                        () {
                          selected_source = source;
                        },
                      );
                    },
                    source: e.value,
                    selected: selected_source?.id == e.value.id,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
