import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';

class Room {
  final String id;
  final List<String> connections_ids;
  final DateTime created;
  final String host_id;

  Room({
    required this.id,
    required this.connections_ids,
    required this.created,
    required this.host_id,
  });

  Room.from_snapshot(
    String id,
    Map<String, dynamic> snapshot,
  )   : id = id,
        connections_ids = snapshot['connections'],
        created = (snapshot['created'] as Timestamp).toDate(),
        host_id = snapshot['host_id'];

  Map<String, dynamic> to_json() {
    return {
      'connections': connections_ids,
      'created': created,
      'host_id': host_id,
    };
  }

  Future<List<Connection>> connections() async {
    QuerySnapshot connections_snap = await FirebaseFirestore.instance
        .collection('connections')
        .where('room_id', isEqualTo: id)
        .get();

    List<Connection> connections = connections_snap.docs.map((connection_snap) {
      return Connection.from_snapshot(
        connection_snap.id,
        connection_snap.data() as Map<String, dynamic>,
      );
    }).toList();
    return connections;
  }
}
