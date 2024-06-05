import 'package:flutter/material.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/peer_row.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/call_smaple.dart';

extension CallSampleStateExtension on CallSampleState {
  Widget contact_list() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      itemCount: peers.length,
      itemBuilder: (context, i) {
        return peer_row(
          context: context,
          peer: peers[i],
          self_id: widget.user_id,
          invite_peer: invite_peer,
        );
      },
    );
  }
}
