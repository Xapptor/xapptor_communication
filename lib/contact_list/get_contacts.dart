import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';

Future<List<Contact>> get_contacts({
  required String user_id,
}) async {
  DocumentSnapshot contacts_snap = await FirebaseFirestore.instance.collection('contacts').doc(user_id).get();
  List<String> contacts_ids = List<String>.from(contacts_snap['contacts']);
  List<Contact> contacts = [];

  for (String contact_id in contacts_ids) {
    DocumentSnapshot contact_snap = await FirebaseFirestore.instance.collection('users').doc(contact_id).get();
    Contact contact = Contact.from_snapshot(contact_id, contact_snap.data() as Map<dynamic, dynamic>);
    contacts.add(contact);
  }
  return contacts;
}
