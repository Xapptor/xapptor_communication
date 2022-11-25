class Connection {
  final String id;
  final String room_id;
  final String source_user_id;
  String destination_user_id;
  final ConnectionOfferAnswer? offer;
  final ConnectionOfferAnswer? answer;

  Connection({
    required this.id,
    required this.room_id,
    required this.source_user_id,
    required this.destination_user_id,
    this.offer,
    this.answer,
  });

  Connection.from_snapshot(
    String id,
    Map<String, dynamic> snapshot,
  )   : id = id,
        room_id = snapshot['room_id'],
        source_user_id = snapshot['source_user_id'],
        destination_user_id = snapshot['destination_user_id'],
        offer = snapshot['offer'] == null
            ? null
            : ConnectionOfferAnswer(
                sdp: snapshot['offer']['sdp'],
                type: snapshot['offer']['type'],
              ),
        answer = ConnectionOfferAnswer(
          sdp: snapshot['answer']['sdp'],
          type: snapshot['answer']['type'],
        );

  Map<String, dynamic> to_json() {
    return {
      'room_id': room_id,
      'source_user_id': source_user_id,
      'destination_user_id': destination_user_id,
      'offer': offer,
      'answer': answer,
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
}
