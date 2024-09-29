import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xapptor_communication/contact_list/add_contact_alert.dart';
import 'package:xapptor_communication/contact_list/contact_list_alert.dart';
import 'package:xapptor_communication/web_rtc_2/call_sample/call_sample.dart';

extension CallSampleStateExtension on CallSampleState {
  ExpandableFab fab_out_of_call() {
    return ExpandableFab(
      key: expandable_fab_key,
      distance: 200,
      duration: const Duration(milliseconds: 150),
      overlayStyle: const ExpandableFabOverlayStyle(
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
        // MARK: Create an Empty Call
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            //signaling?.invite(peer_id, media, use_screen);
          },
          backgroundColor: Colors.pink,
          label: const Icon(
            FontAwesomeIcons.phoneVolume,
            color: Colors.white,
            size: 20,
          ),
        ),

        // MARK: Open Contact List
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => contact_list_alert(
            context: context,
            user_id: widget.user_id,
            signaling: signaling!,
          ),
          backgroundColor: Colors.green,
          label: const Icon(
            FontAwesomeIcons.addressBook,
            color: Colors.white,
            size: 20,
          ),
        ),

        // MARK: Add Contact
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => add_contact_alert(
            context: context,
            user_id: widget.user_id,
          ),
          backgroundColor: Colors.green,
          label: const Icon(
            FontAwesomeIcons.userPlus,
            color: Colors.white,
            size: 20,
          ),
        ),
      ].reversed.toList(),
    );
  }
}
