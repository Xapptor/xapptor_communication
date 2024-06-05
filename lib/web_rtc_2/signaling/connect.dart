import 'package:flutter/foundation.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc_2/utils/turn.dart'
    if (dart.library.js) 'package:xapptor_communication/web_rtc_2/utils/turn_web.dart';

extension SignalingExtension on Signaling {
  Future<void> connect() async {
    var url = 'https://$host:$port/ws';

    debugPrint('connect to $url');

    if (turn_credential == null) {
      try {
        turn_credential = await get_turn_credential(host, port);
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

    // TODO: Implement this
    // socket?.onOpen = () {
    //   debugPrint('onOpen');
    //   on_signaling_state_change?.call(SignalingState.open);
    //   send(
    //     'new',
    //     {
    //       'name': DeviceInfo.label,
    //       'id': self_id,
    //       'user_agent': DeviceInfo.userAgent,
    //     },
    //   );
    // };
  }
}
