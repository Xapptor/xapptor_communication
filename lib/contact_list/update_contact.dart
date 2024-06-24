import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';

enum UpdateContactType {
  add,
  update,
  delete,
}

Future update_contact({
  required String user_id,
  required String contact_id,
  required UpdateContactType update_contact_type,
  bool blocked = false,
}) async {
  DocumentReference contact_reference = FirebaseFirestore.instance.collection('contacts').doc(user_id);

  Map contact = {
    'user_id': contact_id,
    'blocked': blocked,
  };

  if (update_contact_type == UpdateContactType.add) {
    await contact_reference.set(
      {
        'contacts': FieldValue.arrayUnion([contact]),
      },
      SetOptions(merge: true),
    );
  } else if (update_contact_type == UpdateContactType.delete) {
    await contact_reference.update(
      {
        'contacts': FieldValue.arrayRemove([contact]),
      },
    );
  } else if (update_contact_type == UpdateContactType.update) {
    DocumentSnapshot simple_contact_snap = await contact_reference.get();
    List<SimpleContact> simple_contacts = List<SimpleContact>.from(
      simple_contact_snap['contacts'].map(
        (contact) {
          return SimpleContact.from_snapshot(contact);
        },
      ),
    );

    for (var simple_contact in simple_contacts) {
      if (simple_contact.id == contact_id) {
        simple_contact.blocked = blocked;
      }
    }

    await contact_reference.update(
      {
        'contacts': simple_contacts.map((contact) => contact.to_json()).toList(),
      },
    );
  }
}
