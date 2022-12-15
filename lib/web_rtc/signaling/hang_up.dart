import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension HangUp on Signaling {
  Future hang_up() async {
    if (room_id.value != null) {
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

          _delete_connection_candidates(
            connection_ref: connection_ref,
          );
          await connection_ref.delete();
        }
      });

      if (room.host_id == user_id) {
        await room_ref
            .collection('connections')
            .get()
            .then((connections_query_snap) async {
          connections_query_snap.docs
              .asMap()
              .forEach((index, connection_snap) async {
            _delete_connection_candidates(
              connection_ref: connection_snap.reference,
            );
            await connection_snap.reference.delete();

            if (index == connections_query_snap.docs.length - 1) {
              await room_ref.delete();
            }
          });
        });
      }
      remote_streams.forEach((remote_stream) {
        remote_stream.dispose();
      });
    }
  }

  _delete_connection_candidates({
    required DocumentReference connection_ref,
  }) async {
    await connection_ref
        .collection('source_candidates')
        .get()
        .then((value) async {
      for (DocumentSnapshot candidate_snap in value.docs) {
        await candidate_snap.reference.delete();
      }
    });
    await connection_ref
        .collection('destination_candidates')
        .get()
        .then((value) async {
      for (DocumentSnapshot candidate_snap in value.docs) {
        await candidate_snap.reference.delete();
      }
    });
  }
}
