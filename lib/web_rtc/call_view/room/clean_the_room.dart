// ignore_for_file: invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/connection/create_connection_offer.dart';

extension StateExtension on CallViewState {
  clean_the_room() async {
    if (widget.room_id.value != "") {
      remote_renderers.value.clear();
      DocumentReference room_ref = db.collection('rooms').doc(widget.room_id.value);

      await create_connection_offer(
        room_ref: room_ref,
        remote_renderers: remote_renderers,
        setState: setState,
      );
      setState(() {});
    }
  }
}
