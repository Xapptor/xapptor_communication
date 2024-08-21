// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/call_smaple.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/show_accept_dialog.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/show_invite_dialog.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/connect.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension CallSampleStateExtension on CallSampleState {
  void connect(BuildContext context) async {
    signaling ??= Signaling(
      context: context,
      user_id: widget.user_id,
    )..connect();
    signaling?.on_signaling_state_change = (SignalingState state) {
      switch (state) {
        case SignalingState.closed:
        case SignalingState.error:
        case SignalingState.open:
          break;
      }
    };

    signaling?.on_call_state_change = (
      Session? session,
      CallState state,
      Contact? contact,
    ) async {
      switch (state) {
        case CallState.cl_new:
          print('Is not used anymore');
          // Is not used anymore
          setState(() {
            session = session;
          });

          break;
        case CallState.cl_ringing:
          bool? accepted = await show_accept_dialog(context: context);
          if (accepted!) {
            accept();
            setState(() {
              in_calling = true;
            });
          } else {
            reject();
          }

          break;
        case CallState.cl_bye:
          if (wait_accept) {
            debugPrint('peer reject');
            wait_accept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            local_renderer.srcObject = null;
            remote_renderer.srcObject = null;
            in_calling = false;
            session = null;
          });

          break;
        case CallState.cl_invite:
          if (contact != null) {
            wait_accept = true;
            show_invite_dialog(
              context: context,
              hang_up: hang_up,
              contact: contact,
            );
          }

          break;
        case CallState.cl_connected:
          if (wait_accept) {
            wait_accept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            in_calling = true;
          });

          break;
      }
    };

    signaling?.on_peers_update = ((event) {
      setState(() {
        widget.user_id = event['self'];
        peers = event['peers'];
      });
    });

    signaling?.on_local_stream = ((stream) {
      local_renderer.srcObject = stream;
      setState(() {});
    });

    signaling?.on_add_remote_stream = ((_, stream) {
      remote_renderer.srcObject = stream;
      setState(() {});
    });

    signaling?.on_remove_remote_stream = ((_, stream) {
      remote_renderer.srcObject = null;
    });
  }
}
