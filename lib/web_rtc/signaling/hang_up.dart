import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension HangUp on Signaling {
  Future hang_up() async {
    if (remote_stream != null) {
      remote_stream!.getTracks().forEach((track) => track.stop());
    }
    if (peer_connection != null) peer_connection!.close();

    if (room_id != null) {
      DocumentReference room_ref = rooms_ref.doc(room_id);
      DocumentSnapshot room_snap = await room_ref.get();
      Room room = Room.from_snapshot(
          room_id!, room_snap.data() as Map<String, dynamic>);

      room.connections.forEach((connection) async {
        if (connection.source_user_id == user_id ||
            connection.destination_user_id == user_id) {
          DocumentReference connection_ref = connections_ref.doc(connection.id);

          connection_ref.collection('source_candidates').get().then((value) {
            for (DocumentSnapshot ds in value.docs) {
              ds.reference.delete();
            }
          });
          connection_ref
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

      List<Connection> new_room_connections = room.connections;
      new_room_connections.removeWhere((connection) =>
          connection.source_user_id == user_id ||
          connection.destination_user_id == user_id);

      room_ref.update({
        'connections': new_room_connections.map((e) => e.to_json()),
      });
    }
    remote_stream?.dispose();
  }
}
