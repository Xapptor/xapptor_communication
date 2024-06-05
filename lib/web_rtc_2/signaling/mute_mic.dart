import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  void mute_mic() {
    if (local_stream != null) {
      bool enabled = local_stream!.getAudioTracks()[0].enabled;
      local_stream!.getAudioTracks()[0].enabled = !enabled;
    }
  }
}
