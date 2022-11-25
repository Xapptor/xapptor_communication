import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

copy_to_clipboard({
  required String data,
  required String message,
  required BuildContext context,
}) async {
  await Clipboard.setData(
    ClipboardData(
      text: data,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 2000),
    ),
  );
}
