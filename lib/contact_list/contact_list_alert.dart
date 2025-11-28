// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:xapptor_communication/contact_list/add_contact_alert.dart';
import 'package:xapptor_communication/contact_list/contact_list_alert_column_titles.dart';
import 'package:xapptor_communication/contact_list/contact_list_alert_item.dart';
import 'package:xapptor_communication/contact_list/get_contacts.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';
import 'package:xapptor_communication/contact_list/update_contact.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';
import 'package:xapptor_ui/values/ui.dart';

contact_list_alert({
  required BuildContext context,
  required String user_id,
  required Signaling signaling,
}) async {
  bool portrait = is_portrait(context);
  double screen_height = MediaQuery.of(context).size.height;
  double screen_width = MediaQuery.of(context).size.width;

  TextEditingController searchbar_controller = TextEditingController();

  List<Contact> contacts_original = await get_contacts(
    user_id: user_id,
  );

  List<Contact> contacts = contacts_original;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Contact List'),
            content: SizedBox(
              height: screen_height * (portrait ? 0.9 : 0.6),
              width: portrait ? double.maxFinite : screen_width * 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    children: [
                      TextFormField(
                        controller: searchbar_controller,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          suffixIcon: searchbar_controller.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    searchbar_controller.clear();
                                    contacts = contacts_original;
                                    setState(() {});
                                  },
                                ),
                        ),
                        onChanged: (value) {
                          if (value.length > 2) {
                            String value_lower_case = value.toLowerCase();

                            contacts = contacts.where((contact) {
                              return contact.firstname.toLowerCase().contains(value_lower_case) ||
                                  contact.lastname.toLowerCase().contains(value_lower_case) ||
                                  contact.id.toLowerCase().contains(value_lower_case);
                            }).toList();
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: sized_box_space * 3),
                      contacts.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: contacts.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return contact_list_alert_column_titles();
                                } else {
                                  Contact contact = contacts[index - 1];

                                  return contact_list_alert_item(
                                    user_id: user_id,
                                    contact: contact,
                                    blocked: contact.blocked,
                                    blocked_callback: (value) {
                                      contact.blocked = value;
                                      setState(() {});

                                      update_contact(
                                        user_id: user_id,
                                        contact_id: contact.id,
                                        update_contact_type: UpdateContactType.update,
                                        blocked: value,
                                      );
                                    },
                                    delete_callback: () {
                                      contacts.removeAt(index - 1);
                                      setState(() {});

                                      update_contact(
                                        user_id: user_id,
                                        contact_id: contact.id,
                                        update_contact_type: UpdateContactType.delete,
                                        blocked: contact.blocked,
                                      );
                                    },
                                    signaling: signaling,
                                  );
                                }
                              },
                            )
                          : const Text('No contacts found'),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  add_contact_alert(
                    context: context,
                    user_id: user_id,
                  );
                },
                child: const Text('Add Contact'),
              ),
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
    },
  );
}
