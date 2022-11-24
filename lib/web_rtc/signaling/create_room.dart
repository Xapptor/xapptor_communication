import 'package:xapptor_communication/web_rtc/signaling/create_connection_offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/connection.dart';
import 'model/room.dart';
import 'signaling.dart';

extension CreateRoom on Signaling {
  Future<Room> create_room() async {
    String connection_id = await create_connection_offer();
    DocumentReference room_ref = rooms_ref.doc();
    this.room_id = room_ref.id;

    Connection connection = Connection(
      id: connection_id,
      source_user_id: user_id,
      destination_user_id: '',
    );
    Room room = Room(
      id: room_ref.id,
      connections: [connection],
      created: DateTime.now(),
      host_id: user_id,
    );
    await room_ref.set(room.to_json());
    return room;
  }
}
