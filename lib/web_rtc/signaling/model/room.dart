import 'package:cloud_firestore/cloud_firestore.dart';
import 'connection.dart';

class Room {
  final String id;
  final List<Connection> connections;
  final DateTime created;
  final String host_id;

  Room({
    required this.id,
    required this.connections,
    required this.created,
    required this.host_id,
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
        created = (snapshot['created'] as Timestamp).toDate(),
        host_id = snapshot['host_id'];

  Map<String, dynamic> to_json() {
    return {
      'connections': connections.map((e) => e.to_json()),
      'created': created,
      'host_id': host_id,
    };
  }
}
