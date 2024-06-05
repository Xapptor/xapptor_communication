import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';

extension SignalingExtension on Signaling {
  void add_data_channel(
    Session session,
    RTCDataChannel channel,
  ) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      on_data_channel_message?.call(session, channel, data);
    };
    session.dc = channel;
    on_data_channel?.call(session, channel);
  }

  Future<void> create_data_channel(
    Session session, {
    label = 'fileTransfer',
  }) async {
    RTCDataChannelInit data_channel_dict = RTCDataChannelInit()..maxRetransmits = 30;
    RTCDataChannel channel = await session.pc!.createDataChannel(label, data_channel_dict);
    add_data_channel(session, channel);
  }
}
