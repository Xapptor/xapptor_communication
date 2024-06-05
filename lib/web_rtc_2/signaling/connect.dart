import 'package:flutter/foundation.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/enums.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/on_message.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc_2/utils/websocket.dart'
    if (dart.library.js) 'package:xapptor_communication/web_rtc_2/utils/websocket_web.dart';
import 'package:xapptor_communication/web_rtc_2/utils/device_info.dart'
    if (dart.library.js) 'package:xapptor_communication/web_rtc_2/utils/device_info_web.dart';
import 'package:xapptor_communication/web_rtc_2/utils/turn.dart'
    if (dart.library.js) 'package:xapptor_communication/web_rtc_2/utils/turn_web.dart';

extension SignalingExtension on Signaling {
  Future<void> connect() async {
    var url = 'https://$host:$port/ws';
    socket = SimpleWebSocket(url);

    debugPrint('connect to $url');

    if (turn_credential == null) {
      try {
        turn_credential = await getTurnCredential(host, port);
        /*{
            "username": "1584195784:mbzrxpgjys",
            "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
            "ttl": 86400,
            "uris": ["turn:127.0.0.1:19302?transport=udp"]
          }
        */
        ice_servers = {
          'iceServers': [
            {
              'urls': turn_credential!['uris'][0],
              'username': turn_credential!['username'],
              'credential': turn_credential!['password']
            },
          ]
        };
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    socket?.onOpen = () {
      debugPrint('onOpen');
      on_signaling_state_change?.call(SignalingState.open);
      send(
        'new',
        {
          'name': DeviceInfo.label,
          'id': self_id,
          'user_agent': DeviceInfo.userAgent,
        },
      );
    };

    socket?.onMessage = (message) {
      debugPrint('Received data: $message');
      on_message(decoder.convert(message));
    };

    socket?.onClose = (int? code, String? reason) {
      debugPrint('Closed by server [$code => $reason]!');
      on_signaling_state_change?.call(SignalingState.closed);
    };

    await socket?.connect();
  }
}
