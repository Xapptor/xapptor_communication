import 'package:flutter/material.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';

Future<bool?> show_invite_dialog({
  required BuildContext context,
  required Function hang_up,
  required Contact contact,
}) {
  String contact_name = "${contact.firstname} ${contact.lastname}";
  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Waiting for $contact_name to accept the call'),
        content: const Text("waiting"),
        actions: [
          TextButton(
            child: const Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
              hang_up();
            },
          ),
        ],
      );
    },
  );
}
