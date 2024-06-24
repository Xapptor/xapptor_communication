import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';

Widget contact_list_alert_item({
  required String user_id,
  required Contact contact,
  required bool blocked,
  required Function blocked_callback,
  required Function delete_callback,
}) {
  WidgetStatePropertyAll<Icon> thumb_icon = WidgetStatePropertyAll(
    Icon(
      blocked ? Icons.block : Icons.check_circle,
    ),
  );

  WidgetStatePropertyAll<Color> thumb_color = WidgetStatePropertyAll(
    blocked ? Colors.red : Colors.green,
  );

  String contact_info = '${contact.firstname} ${contact.lastname}';
  String short_contact_id = '${contact.id.substring(0, 4)}...${contact.id.substring(contact.id.length - 4)}';
  contact_info += '\nID: $short_contact_id';

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              contact_info,
            ),
            IconButton(
              icon: const Icon(
                Icons.copy,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: contact.id));
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.call,
              ),
              onPressed: () {
                //signaling?.invite(peer_id, media, use_screen);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.video_call,
              ),
              onPressed: () {
                //signaling?.invite(peer_id, media, use_screen);
              },
            ),
          ],
        ),
        Switch(
          value: blocked,
          thumbIcon: thumb_icon,
          thumbColor: thumb_color,
          onChanged: (value) => blocked_callback(value),
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => delete_callback(),
          ),
        ),
      ],
    ),
  );
}
