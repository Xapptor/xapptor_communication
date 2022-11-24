import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';

class RoomInfo extends StatelessWidget {
  final Color background_color;
  final String room_id;
  final String call_base_url;
  final Color main_color;
  final Function callback;

  const RoomInfo({
    required this.background_color,
    required this.room_id,
    required this.call_base_url,
    required this.main_color,
    required this.callback,
  });

  final double title_size = 14;

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_height = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: background_color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  callback();
                },
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screen_height * (portrait ? 0.3 : 0.2),
                  padding: const EdgeInsets.all(8),
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: room_id,
                  ),
                ),
                Text(
                  "Room ID:",
                  style: TextStyle(
                    color: main_color,
                    fontSize: title_size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    ClipboardData data = ClipboardData(
                      text: room_id,
                    );
                    await Clipboard.setData(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("ID copied to clipboard"),
                        duration: Duration(milliseconds: 2000),
                      ),
                    );
                    callback();
                  },
                  child: Text(
                    room_id,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: main_color,
                      fontSize: title_size,
                    ),
                  ),
                ),
                SizedBox(height: sized_box_space),
                Text(
                  "Room URL:",
                  style: TextStyle(
                    color: main_color,
                    fontSize: title_size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    ClipboardData data = ClipboardData(
                      text: call_base_url + room_id,
                    );
                    await Clipboard.setData(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("URL copied to clipboard"),
                        duration: Duration(milliseconds: 2000),
                      ),
                    );
                    callback();
                  },
                  child: Text(
                    call_base_url + room_id,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: main_color,
                      fontSize: title_size,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
