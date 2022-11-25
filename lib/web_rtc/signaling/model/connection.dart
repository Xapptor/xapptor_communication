import 'package:cloud_firestore/cloud_firestore.dart';

class Connection {
  final String id;
  final DateTime created;
  final String source_user_id;
  String destination_user_id;
  final ConnectionOfferAnswer? offer;
  final ConnectionOfferAnswer? answer;

  Connection({
    required this.id,
    required this.created,
    required this.source_user_id,
    required this.destination_user_id,
    this.offer,
    this.answer,
  });

  Connection.from_snapshot(
    String id,
    Map<String, dynamic> snapshot,
  )   : id = id,
        created = (snapshot['created'] as Timestamp).toDate(),
        source_user_id = snapshot['source_user_id'],
        destination_user_id = snapshot['destination_user_id'],
        offer = snapshot['offer'] == null
            ? null
            : ConnectionOfferAnswer(
                sdp: snapshot['offer']['sdp'],
                type: snapshot['offer']['type'],
              ),
        answer = snapshot['answer'] == null
            ? null
            : ConnectionOfferAnswer(
                sdp: snapshot['answer']['sdp'],
                type: snapshot['answer']['type'],
              );

  Map<String, dynamic> to_json() {
    return {
      'created': created,
      'source_user_id': source_user_id,
      'destination_user_id': destination_user_id,
      'offer': offer?.to_json(),
      'answer': answer?.to_json(),
    };
  }
}

class ConnectionOfferAnswer {
  final String sdp;
  final String type;

  ConnectionOfferAnswer({
    required this.sdp,
    required this.type,
  });

  factory ConnectionOfferAnswer.from_map(Map<String, dynamic> map) {
    return ConnectionOfferAnswer(
      sdp: map['sdp'],
      type: map['type'],
    );
  }

  Map<String, dynamic> to_json() {
    return {
      'sdp': sdp,
      'type': type,
    };
  }
}
