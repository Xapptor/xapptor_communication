// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/call_view/call_view.dart';
import 'package:xapptor_communication/web_rtc/call_view/clean_the_room.dart';
import 'package:xapptor_communication/web_rtc/call_view/exit_from_room.dart';
import 'package:xapptor_communication/web_rtc/listen_connections.dart';
import 'package:xapptor_communication/web_rtc/signaling/join_room.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';
import 'package:xapptor_router/update_path/update_path.dart';

extension StateExtension on CallViewState {
  join_room(String room_id) async {
    await signaling.join_room(
      room_id: widget.room_id.value,
      remote_renderers: remote_renderers,
      setState: setState,
    );
    in_a_call.value = true;

    DocumentSnapshot room_snap = await db.collection('rooms').doc(widget.room_id.value).get();

    room = Room.from_snapshot(room_snap.id, room_snap.data() as Map<String, dynamic>);

    if (context.mounted) {
      listen_connections(
        user_id: widget.user_id,
        remote_renderers: remote_renderers,
        setState: setState,
        signaling: signaling,
        clean_the_room: clean_the_room,
        exit_from_room: exit_from_room,
        connections_listener: connections_listener,
        context: context,
        room: room!,
      );
    }
    update_path('home/room/${widget.room_id.value}');
    setState(() {});
  }
}
