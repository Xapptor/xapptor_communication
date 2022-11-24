class ConnectionDetail {
  final String id;
  final String source_user_id;
  String destination_user_id;

  ConnectionDetail({
    required this.id,
    required this.source_user_id,
    required this.destination_user_id,
  });

  ConnectionDetail.from_snapshot(
    String id,
    Map<String, dynamic> snapshot,
  )   : id = id,
        source_user_id = snapshot['source_user_id'],
        destination_user_id = snapshot['destination_user_id'];

  Map<String, dynamic> to_json() {
    return {
      'id': id,
      'source_user_id': source_user_id,
      'destination_user_id': destination_user_id,
    };
  }
}
