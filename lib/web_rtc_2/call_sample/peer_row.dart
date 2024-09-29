import 'package:flutter/material.dart';

Widget peer_row({
  required BuildContext context,
  required Map peer,
  required String self_id,
  required Function invite_peer,
}) {
  var self = peer['id'] == self_id;

  String title = peer['name'] + ', ID: ${peer['id']}';

  if (self) {
    title += ' [Your self]';
  }

  return ListBody(
    children: [
      ListTile(
        title: SelectableText(
          title,
        ),
        onTap: null,
        trailing: SizedBox(
          width: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  self ? Icons.close : Icons.videocam,
                  color: self ? Colors.grey : Colors.black,
                ),
                onPressed: () => invite_peer(context, peer['id'], false),
                tooltip: 'Video calling',
              ),
              IconButton(
                icon: Icon(
                  self ? Icons.close : Icons.screen_share,
                  color: self ? Colors.grey : Colors.black,
                ),
                onPressed: () => invite_peer(context, peer['id'], true),
                tooltip: 'Screen sharing',
              )
            ],
          ),
        ),
        subtitle: Text('[${peer['user_agent']}]'),
      ),
      const Divider()
    ],
  );
}
