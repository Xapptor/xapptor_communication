// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:xapptor_communication/contact_list/update_contact.dart';
import 'package:xapptor_logic/user/check_if_user_exist.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';
import 'package:xapptor_ui/utils/show_alert.dart';

add_contact_alert({
  required BuildContext context,
  required String user_id,
}) async {
  bool portrait = is_portrait(context);
  double screen_width = MediaQuery.of(context).size.width;

  TextEditingController new_contact_controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Contact'),
        content: SizedBox(
          width: portrait ? double.maxFinite : screen_width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: new_contact_controller,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              bool do_user_exist = await check_if_user_exist_by_id(user_id: new_contact_controller.text);

              if (do_user_exist) {
                await update_contact(
                  user_id: user_id,
                  contact_id: new_contact_controller.text,
                  update_contact_type: UpdateContactType.add,
                );
                show_success_alert(
                  context: context,
                  message: 'Contact added successfully',
                );
              } else {
                show_error_alert(
                  context: context,
                  message: 'The user does not exist',
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
