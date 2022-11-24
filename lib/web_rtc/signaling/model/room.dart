import 'package:cloud_firestore/cloud_firestore.dart';
import 'connection.dart';

class Room {
  final String id;
  final List<Connection> connections;
  final DateTime created;

  Room({
    required this.id,
    required this.connections,
    required this.created,
  });

  Room.from_snapshot(
    String id,
    Map<String, dynamic> snapshot,
  )   : id = id,
        connections = List<Connection>.from(
          snapshot['connections'].map((connection) {
            return Connection.from_snapshot(connection['id'], connection);
          }).toList(),
        ),
        created = (snapshot['created'] as Timestamp).toDate();

  Map<String, dynamic> to_json() {
    return {
      'connections': connections.map((e) => e.to_json()),
      'created': created,
    };
  }
}
