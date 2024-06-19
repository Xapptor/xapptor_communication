import 'package:cloud_firestore/cloud_firestore.dart';

enum UpdateContactType {
  add,
  remove,
}

Future update_contact({
  required String user_id,
  required String contact_id,
  required UpdateContactType update_contact_type,
}) async {
  Map contact = {
    'user_id': contact_id,
    'blocked': false,
  };

  await FirebaseFirestore.instance.collection('contacts').doc(user_id).set(
    {
      'contacts': update_contact_type == UpdateContactType.add
          ? FieldValue.arrayUnion([contact])
          : FieldValue.arrayRemove([contact]),
    },
    SetOptions(merge: true),
  );
}
