import 'package:flutter/material.dart';

Future<bool?> show_invate_dialog({
  required BuildContext context,
  required Function hang_up,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("title"),
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
