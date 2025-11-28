import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/button_bar.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/get_sources.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/tab_bar_view.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog({
    super.key,
  }) {
    Future.delayed(const Duration(milliseconds: 100), () {
      get_sources();
    });

    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      sources[source.id] = source;
      state_setter?.call(() {});
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      sources.remove(source.id);
      state_setter?.call(() {});
    }));

    _subscriptions.add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      state_setter?.call(() {});
    }));
  }

  final Map<String, DesktopCapturerSource> sources = {};
  SourceType source_type = SourceType.Screen;
  DesktopCapturerSource? selected_source;
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  StateSetter? state_setter;
  Timer? timer;

  void _ok(context) async {
    timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, selected_source);
  }

  void _cancel(context) async {
    timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 640,
          height: 560,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Choose what to share',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: const Icon(Icons.close),
                        onTap: () => _cancel(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      state_setter = setState;
                      return DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints.expand(height: 24),
                              child: TabBar(
                                onTap: (value) => Future.delayed(const Duration(milliseconds: 300), () {
                                  source_type = value == 0 ? SourceType.Screen : SourceType.Window;
                                  get_sources();
                                }),
                                tabs: const [
                                  Tab(
                                    child: Text(
                                      'Entire Screen',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      'Window',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: tab_bar_view(
                                setState: setState,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: button_bar(
                  context: context,
                  cancel: _cancel,
                  ok: _ok,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
