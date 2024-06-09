import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/call_smaple.dart';

extension CallSampleStateExtension on CallSampleState {
  ExpandableFab fab_on_call({
    required GlobalKey expandable_fab_key,
  }) {
    return ExpandableFab(
      key: expandable_fab_key,
      distance: 200,
      duration: const Duration(milliseconds: 150),
      overlayStyle: ExpandableFabOverlayStyle(
        blur: 5,
      ),
      openButtonBuilder: FloatingActionButtonBuilder(
        size: 20,
        builder: (context, onPressed, progress) {
          return FloatingActionButton(
            heroTag: null,
            onPressed: onPressed,
            child: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          );
        },
      ),
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 20,
        builder: (context, onPressed, progress) {
          return FloatingActionButton(
            heroTag: null,
            onPressed: onPressed,
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          );
        },
      ),
      children: [
        // MARK: Camera
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            signaling?.toggle_camera();
          },
          backgroundColor: Colors.pink,
          label: const Icon(
            FontAwesomeIcons.video,
            color: Colors.white,
            size: 20,
          ),
        ),

        // MARK: Screen Sharing
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            //signaling?.switch_to_screen_sharing(screen_stream);
          },
          backgroundColor: Colors.green,
          label: Icon(
            UniversalPlatform.isMobile ? FontAwesomeIcons.mobileScreen : FontAwesomeIcons.display,
            color: Colors.white,
            size: 20,
          ),
        ),

        // MARK: Hang Up
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            hang_up();
          },
          backgroundColor: Colors.green,
          label: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.white,
            size: 20,
          ),
        ),

        // MARK: Mute
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            mute_mic();
          },
          backgroundColor: Colors.green,
          label: Icon(
            signaling == null
                ? FontAwesomeIcons.microphoneSlash
                : signaling!.is_mute
                    ? FontAwesomeIcons.microphoneSlash
                    : FontAwesomeIcons.microphone,
            color: Colors.white,
            size: 20,
          ),
        ),
      ].reversed.toList(),
    );
  }
}
