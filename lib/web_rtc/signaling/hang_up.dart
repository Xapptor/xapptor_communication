import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension HangUp on Signaling {
  Future hang_up() async {
    if (room_id != null) {
      remote_streams.forEach((remote_stream) {
        remote_stream.getTracks().forEach((track) => track.stop());
      });
      peer_connections.forEach((peer_connection) {
        peer_connection.value.close();
      });

      DocumentReference room_ref = rooms_ref.doc(room_id.value);
      DocumentSnapshot room_snap = await room_ref.get();
      Room room = Room.from_snapshot(
          room_id.value!, room_snap.data() as Map<String, dynamic>);

      List<Connection> connections = await room.connections();

      connections.forEach((connection) async {
        if (connection.source_user_id == user_id ||
            connection.destination_user_id == user_id) {
          DocumentReference connection_ref =
              room_ref.collection('connections').doc(connection.id);

          await connection_ref
              .collection('source_candidates')
              .get()
              .then((value) {
            for (DocumentSnapshot ds in value.docs) {
              ds.reference.delete();
            }
          });
          await connection_ref
              .collection('destination_candidates')
              .get()
              .then((value) {
            for (DocumentSnapshot ds in value.docs) {
              ds.reference.delete();
            }
          });
          await connection_ref.delete();
        }
      });

      if (room.host_id == user_id) {
        room_ref.delete();
      }
      remote_streams.forEach((remote_stream) {
        remote_stream.dispose();
      });
    }
  }
}