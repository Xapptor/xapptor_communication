import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

class RoomInfoContainer extends StatelessWidget {
  final String room_id;
  final String call_base_url;
  final Color main_color;

  const RoomInfoContainer({
    required this.room_id,
    required this.call_base_url,
    required this.main_color,
  });

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: screen_height * (portrait ? 0.5 : 0.15),
        child: Flex(
          direction: portrait ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: room_id,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Room ID:",
                  style: TextStyle(
                    color: main_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    ClipboardData data = ClipboardData(
                      text: room_id,
                    );
                    await Clipboard.setData(data);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("ID copied to clipboard"),
                      duration: Duration(milliseconds: 300),
                    ));
                  },
                  child: Text(
                    room_id,
                    style: TextStyle(
                      color: main_color,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: sized_box_space),
                Text(
                  "Room URL:",
                  style: TextStyle(
                    color: main_color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    ClipboardData data = ClipboardData(
                      text: call_base_url + room_id,
                    );
                    await Clipboard.setData(data);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("URL copied to clipboard"),
                      duration: Duration(milliseconds: 300),
                    ));
                  },
                  child: Text(
                    call_base_url + room_id,
                    style: TextStyle(
                      color: main_color,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
