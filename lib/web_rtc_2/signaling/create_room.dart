import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/model/room.dart';
import 'package:xapptor_logic/random/generate_random_id.dart';
import 'package:xapptor_db/xapptor_db.dart';

Future<Room> create_room({
  required String user_id,
}) async {
  String temp_id = generate_random_id();
  DocumentReference room_ref = XapptorDB.instance.collection('rooms').doc();

  Room room = Room(
    id: '',
    created: DateTime.now(),
    host_id: user_id,
    temp_id: temp_id,
  );

  Map room_json = room.to_json();
  room_json['created'] = FieldValue.serverTimestamp();
  await room_ref.set(room_json);
  room.id = room_ref.id;

  return room;
}
