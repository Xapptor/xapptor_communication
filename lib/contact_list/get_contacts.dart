import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';
import 'package:xapptor_db/xapptor_db.dart';

Future<List<Contact>> get_contacts({
  required String user_id,
}) async {
  DocumentSnapshot contacts_snap = await XapptorDB.instance.collection('contacts').doc(user_id).get();

  if (contacts_snap.data() == null) {
    return [];
  } else {
    List<Map> contacts_maps = List<Map>.from(contacts_snap['contacts'] ?? []);
    List<Contact> contacts = [];

    for (var contacts_map in contacts_maps) {
      String contact_id = contacts_map['user_id'];
      bool contact_blocked = contacts_map['blocked'];

      Contact contact = await check_if_contact_exists(
            id: contact_id,
            blocked: contact_blocked,
          ) ??
          Contact.empty(
            id: contact_id,
            blocked: contact_blocked,
          );

      contacts.add(contact);
    }
    return contacts;
  }
}
