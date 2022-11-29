import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/room.dart';

class User {
  final String id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  User.from_snapshot({
    required String id,
    required Map<String, dynamic> snapshot,
  })  : id = id,
        name = snapshot['firstname'] + ' ' + snapshot['lastname'];

  Future<List<User>> get_room_users_from_room_id(String room_id) async {
    DocumentSnapshot room_snap =
        await FirebaseFirestore.instance.collection('rooms').doc(room_id).get();
    Room room =
        Room.from_snapshot(room_id, room_snap.data() as Map<String, dynamic>);

    List<Connection> connections = await room.connections();
    List<String> users_ids = get_users_ids_from_connection_list(connections);
    List<User> users = await _convert_users_ids_to_users(users_ids);
    return users;
  }

  Future<List<User>> get_room_users_from_connections(
      List<Connection> connections) async {
    List<String> users_ids = get_users_ids_from_connection_list(connections);
    List<User> users = await _convert_users_ids_to_users(users_ids);
    return users;
  }

  Future<List<User>> _convert_users_ids_to_users(List<String> users_ids) async {
    List<User> users = [];
    await Future.forEach(users_ids, (String user_id) async {
      DocumentSnapshot user_snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user_id)
          .get();

      User user = User.from_snapshot(
        id: user_id,
        snapshot: user_snap.data() as Map<String, dynamic>,
      );
      users.add(user);
    });
    return users;
  }
}

List<String> get_users_ids_from_connection_list(List<Connection> connections) {
  List<String> original_user_ids = [];
  List<String> final_user_ids = [];

  connections.forEach((connection) {
    original_user_ids.add(connection.source_user_id);
    original_user_ids.add(connection.destination_user_id);
  });
  original_user_ids.forEach((user_id) {
    if (!final_user_ids.contains(user_id)) {
      final_user_ids.add(user_id);
    }
  });
  return final_user_ids;
}
