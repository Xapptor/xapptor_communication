import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  Future<void> clean_essions() async {
    if (local_stream != null) {
      local_stream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await local_stream!.dispose();
      local_stream = null;
    }
    sessions.forEach((key, session) async {
      await session.peer_connection?.close();
      await session.data_channel?.close();
    });
    sessions.clear();
  }
}
