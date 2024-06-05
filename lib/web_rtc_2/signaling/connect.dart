import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<void> connect() async {
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
