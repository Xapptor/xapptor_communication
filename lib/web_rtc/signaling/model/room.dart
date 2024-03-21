import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/web_rtc/signaling/model/connection.dart';

class Room {
  final String id;
  final DateTime created;
  final String host_id;
  final String temp_id;

  Room({
    required this.id,
    required this.created,
    required this.host_id,
    required this.temp_id,
  });

  Room.from_snapshot(
    this.id,
    Map<String, dynamic> snapshot,
  )   : created = (snapshot['created'] as Timestamp).toDate(),
        host_id = snapshot['host_id'],
        temp_id = snapshot['temp_id'];

  Map<String, dynamic> to_json() {
    return {
      'created': created,
      'host_id': host_id,
      'temp_id': temp_id,
    };
  }

  Future<List<Connection>> connections() async {
    QuerySnapshot connections_snap =
        await FirebaseFirestore.instance.collection('rooms').doc(id).collection('connections').get();

    List<Connection> connections = connections_snap.docs.map((connection_snap) {
      return Connection.from_snapshot(
        connection_snap.id,
        connection_snap.data() as Map<String, dynamic>,
      );
    }).toList();
    return connections;
  }
}
