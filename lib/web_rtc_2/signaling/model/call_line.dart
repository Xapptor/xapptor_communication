class CallLine {
  String id;
  String caller_id;
  String room_id;
  String session_id;

  CallLine({
    required this.id,
    required this.caller_id,
    required this.room_id,
    required this.session_id,
  });

  CallLine.from_snapshot(
    this.id,
    Map<dynamic, dynamic> snapshot,
  )   : caller_id = snapshot['caller_id'] ?? '',
        room_id = snapshot['room_id'] ?? '',
        session_id = snapshot['session_id'] ?? '';

  Map<String, dynamic> to_json() {
    return {
      'caller_id': caller_id,
      'room_id': room_id,
      'session_id': session_id,
    };
  }
}
