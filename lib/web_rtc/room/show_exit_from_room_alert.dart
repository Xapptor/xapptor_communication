import 'dart:async';
import 'package:flutter/material.dart';

show_exit_from_room_alert({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    ),
  );

  Timer(const Duration(seconds: 3), () {
    Navigator.pop(context);
  });
}
