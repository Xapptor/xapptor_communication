import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_anwser.dart';
import 'package:xapptor_communication/web_rtc/signaling/create_connection_offer.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension JoinRoom on Signaling {
  Future join_room({
    required String room_id,
  }) async {
    DocumentReference room_ref = rooms_ref.doc(room_id);
    DocumentSnapshot room_snap = await room_ref.get();
    Room room =
        Room.from_snapshot(room_id, room_snap.data() as Map<String, dynamic>);

    List<Connection> connections = await room.connections();
    List<String> pending_connections_id = connections
        .where((element) => element.destination_user_id == '')
        .map(
          (e) => e.id,
        )
        .toList();

    if (pending_connections_id.length > 0) {
      pending_connections_id.forEach((pending_connection_id) async {
        Connection current_connection = connections
            .firstWhere((element) => element.id == pending_connection_id);

        create_connection_anwser(
          connection: current_connection,
          room_ref: room_ref,
        );
      });
    } else {
      List<String> user_ids = [];
      connections.forEach((connection) {
        user_ids.add(connection.source_user_id);
        user_ids.add(connection.destination_user_id);
      });
      user_ids = user_ids.toSet().toList();
      print('user_ids: $user_ids');

      user_ids.forEach((user_id) async {
        String connection_id = await create_connection_offer(
          destination_user_id: user_id,
        );

        Connection connection = Connection(
          id: connection_id,
          room_id: room_id,
          source_user_id: this.user_id,
          destination_user_id: user_id,
        );
        room_ref.update({
          'connections': FieldValue.arrayUnion([connection.id]),
        });
      });
    }
  }
}
