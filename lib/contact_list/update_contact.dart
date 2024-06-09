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
  DocumentReference doc_reference = FirebaseFirestore.instance.collection('contacts').doc(user_id);
  List contact_id_array = [contact_id];

  FieldValue field_value = update_contact_type == UpdateContactType.add
      ? FieldValue.arrayUnion(contact_id_array)
      : FieldValue.arrayRemove(contact_id_array);

  Map<String, dynamic> contact_array_map = {
    'contacts': field_value,
  };
  await doc_reference.update(contact_array_map);
}
