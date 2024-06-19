// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:xapptor_communication/contact_list/get_contacts.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';

contact_list_alert({
  required BuildContext context,
  required String user_id,
}) async {
  bool portrait = is_portrait(context);
  double screen_width = MediaQuery.of(context).size.width;

  TextEditingController searchbar_controller = TextEditingController();

  List<Contact> contacts = await get_contacts(
    user_id: user_id,
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Contact List'),
        content: SizedBox(
          width: portrait ? double.maxFinite : screen_width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('You can select a contact to call'),
              TextFormField(
                controller: searchbar_controller,
                decoration: const InputDecoration(
                  labelText: 'Search',
                ),
                onChanged: (value) {
                  if (value.length > 2) {
                    //
                  }
                },
              ),
              contacts.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Contact $index'),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    )
                  : const Text('No contacts found'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
