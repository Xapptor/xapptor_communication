import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/model/user.dart';
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

    if (connections.length > 1) {
      create_pending_connections(
        connections: connections,
        room_ref: room_ref,
      );
    } else if (connections.length == 1) {
      if (connections.first.destination_user_id == '') {
        create_connection_anwser(
          connection: connections.first,
          room_ref: room_ref,
        );
      } else {
        create_pending_connections(
          connections: connections,
          room_ref: room_ref,
        );
      }
    }
  }

  create_pending_connections({
    required List<Connection> connections,
    required DocumentReference room_ref,
  }) {
    List<String> user_ids = get_users_ids_from_connection_list(connections);
    user_ids.forEach((user_id) async {
      await create_connection_offer(
        destination_user_id: user_id,
        room_ref: room_ref,
      );
    });
  }
}
