import 'package:flutter/material.dart';

Widget button_bar({
  required BuildContext context,
  required Function(BuildContext context) cancel,
  required Function(BuildContext context) ok,
}) {
  return ButtonBar(
    children: [
      MaterialButton(
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        onPressed: () {
          cancel(context);
        },
      ),
      MaterialButton(
        color: Theme.of(context).primaryColor,
        child: const Text(
          'Share',
        ),
        onPressed: () {
          ok(context);
        },
      ),
    ],
  );
}
