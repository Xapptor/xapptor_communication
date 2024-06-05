import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/utils/screen_select_dialog/screen_select_dialog.dart';

extension CallSampleStateExtension on ScreenSelectDialog {
  Future<void> get_sources() async {
    try {
      var my_sources = await desktopCapturer.getSources(types: [source_type]);
      for (var my_source in my_sources) {
        debugPrint('name: ${my_source.name}, id: ${my_source.id}, type: ${my_source.type}');
      }

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        desktopCapturer.updateSources(types: [source_type]);
      });
      sources.clear();

      for (var my_source in my_sources) {
        sources[my_source.id] = my_source;
      }
      state_setter?.call(() {});
      return;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
