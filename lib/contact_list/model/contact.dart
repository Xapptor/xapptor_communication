class Contact {
  String id;
  String firstname;
  String lastname;
  String photo_url;
  bool blocked;

  Contact({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.photo_url,
    required this.blocked,
  });

  Contact.from_snapshot(
    this.id,
    this.blocked,
    Map<dynamic, dynamic> snapshot,
  )   : firstname = snapshot['firstname'] ?? '',
        lastname = snapshot['lastname'] ?? '',
        photo_url = snapshot['photo_url'] ?? '';

  Map<String, dynamic> to_json() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'photo_url': photo_url,
      'blocked': blocked,
    };
  }
}

class SimpleContact {
  String id;
  bool blocked;

  SimpleContact({
    required this.id,
    required this.blocked,
  });

  SimpleContact.from_snapshot(
    Map<dynamic, dynamic> snapshot,
  )   : id = snapshot['user_id'] ?? '',
        blocked = snapshot['blocked'] ?? '';

  Map<String, dynamic> to_json() {
    return {
      'user_id': id,
      'blocked': blocked,
    };
  }
}
