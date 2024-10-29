import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String id;
  String firstname;
  String lastname;
  String photo_url;
  bool blocked;
  bool exists;

  Contact({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.photo_url,
    required this.blocked,
    required this.exists,
  });

  Contact.from_snapshot(
    this.id,
    this.blocked,
    Map<dynamic, dynamic> snapshot,
  )   : firstname = snapshot['firstname'] ?? '',
        lastname = snapshot['lastname'] ?? '',
        photo_url = snapshot['photo_url'] ?? '',
        exists = false;

  factory Contact.empty({
    String id = '',
    bool blocked = false,
  }) {
    return Contact(
      id: id,
      firstname: '',
      lastname: '',
      photo_url: '',
      blocked: blocked,
      exists: false,
    );
  }

  Map<String, dynamic> to_json() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'photo_url': photo_url,
      'blocked': blocked,
      'exists': exists,
    };
  }
}

Future<Contact?> check_if_contact_exists({
  required String id,
  required bool blocked,
}) async {
  DocumentSnapshot contact_snap = await FirebaseFirestore.instance.collection('users').doc(id).get();

  Contact? contact;

  if (contact_snap.data() != null) {
    contact = Contact.from_snapshot(
      id,
      blocked,
      contact_snap.data() as Map<dynamic, dynamic>,
    );
    contact.exists = true;
  }
  return contact;
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
