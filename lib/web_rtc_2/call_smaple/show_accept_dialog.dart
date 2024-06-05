import 'package:flutter/material.dart';

Future<bool?> show_accept_dialog({
  required BuildContext context,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("title"),
        content: const Text("accept?"),
        actions: [
          MaterialButton(
            child: const Text(
              'Reject',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          MaterialButton(
            child: const Text(
              'Accept',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
