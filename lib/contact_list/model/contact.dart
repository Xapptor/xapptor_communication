class Contact {
  String id;
  String name;
  String email;
  String photo_url;
  bool blocked;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.photo_url,
    required this.blocked,
  });

  Contact.from_snapshot(
    this.id,
    Map<dynamic, dynamic> snapshot,
  )   : name = snapshot['name'],
        email = snapshot['email'],
        photo_url = snapshot['photo_url'],
        blocked = snapshot['blocked'];

  Map<String, dynamic> to_json() {
    return {
      'name': name,
      'email': email,
      'photo_url': photo_url,
      'blocked': blocked,
    };
  }
}
