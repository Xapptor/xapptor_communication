import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';

Future<List<Contact>> get_contacts({
  required String user_id,
}) async {
  DocumentSnapshot contacts_snap = await FirebaseFirestore.instance.collection('contacts').doc(user_id).get();

  if (contacts_snap.data() == null) {
    return [];
  } else {
    List<Map> contacts_maps = List<Map>.from(contacts_snap['contacts'] ?? []);
    List<Contact> contacts = [];

    for (var contacts_map in contacts_maps) {
      String contact_id = contacts_map['user_id'];
      bool contact_blocked = contacts_map['blocked'];

      DocumentSnapshot contact_snap = await FirebaseFirestore.instance.collection('users').doc(contact_id).get();

      Contact contact = Contact.from_snapshot(
        contact_id,
        contact_blocked,
        contact_snap.data() as Map<dynamic, dynamic>,
      );
      contacts.add(contact);
    }
    return contacts;
  }
}
