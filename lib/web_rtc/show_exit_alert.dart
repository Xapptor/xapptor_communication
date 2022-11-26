import 'dart:async';

import 'package:flutter/material.dart';

show_exit_alert({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
    ),
  );

  Timer(Duration(seconds: 4), () {
    Navigator.pop(context);
  });
}