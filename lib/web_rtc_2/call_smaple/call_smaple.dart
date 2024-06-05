// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/connect.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/contact_list.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/floating_action_button.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/select_screen_source_dialog.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/invite.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/mute_mic.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/switch_camera.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/switch_to_screen_sharing.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';
  String user_id;

  CallSample({
    super.key,
    required this.user_id,
  });

  @override
  State<CallSample> createState() => CallSampleState();
}

class CallSampleState extends State<CallSample> {
  Signaling? signaling;
  List<dynamic> peers = [
    {
      'id': 'FcqQqDVf8FNmF9tw1TsmZhykr8G3',
      'name': 'My name',
      'user_agent': 'Flutter',
    },
    {
      'id': '1',
      'name': 'User 1',
      'user_agent': 'Flutter',
    },
    {
      'id': '2',
      'name': 'User 2',
      'user_agent': 'Flutter',
    },
    {
      'id': '3',
      'name': 'User 3',
      'user_agent': 'Flutter',
    },
    {
      'id': '4',
      'name': 'User 4',
      'user_agent': 'Flutter',
    },
    {
      'id': '5',
      'name': 'User 5',
      'user_agent': 'Flutter',
    },
    {
      'id': '6',
      'name': 'User 6',
      'user_agent': 'Flutter',
    },
    {
      'id': '7',
      'name': 'User 7',
      'user_agent': 'Flutter',
    },
    {
      'id': '8',
      'name': 'User 8',
      'user_agent': 'Flutter',
    },
    {
      'id': '9',
      'name': 'User 9',
      'user_agent': 'Flutter',
    },
    {
      'id': '10',
      'name': 'User 10',
      'user_agent': 'Flutter',
    },
  ];
  final RTCVideoRenderer local_renderer = RTCVideoRenderer();
  final RTCVideoRenderer remote_renderer = RTCVideoRenderer();
  bool in_calling = false;
  Session? _session;
  DesktopCapturerSource? desktop_capturer_selected_source;
  bool wait_accept = false;

  @override
  initState() {
    super.initState();
    init_renderers();
    connect(context);
  }

  init_renderers() async {
    await local_renderer.initialize();
    await remote_renderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    signaling?.close();
    local_renderer.dispose();
    remote_renderer.dispose();
  }

  invite_peer(
    BuildContext context,
    String new_peer_id,
    bool use_screen,
  ) async {
    if (signaling != null && new_peer_id != widget.user_id) {
      signaling?.invite(
        new_peer_id,
        'video',
        use_screen,
      );
    }
  }

  accept() {
    if (_session != null) signaling?.accept(_session!.id, 'video');
  }

  reject() {
    if (_session != null) signaling?.reject(_session!.id);
  }

  hang_up() {
    if (_session != null) signaling?.bye(_session!.id);
  }

  mute_mic() => signaling?.mute_mic();

  @override
  Widget build(BuildContext context) {
    String title = 'P2P Call Sample - Your ID (${widget.user_id})';
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(title),
        actions: const [
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: null,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floating_action_button(
        context: context,
        switch_camera: signaling!.switch_camera,
        select_screen_source_dialog: () => select_screen_source_dialog(
          context: context,
          switch_to_screen_sharing: (screen_stream) {
            signaling?.switch_to_screen_sharing(screen_stream);
          },
        ),
        hang_up: hang_up,
        in_calling: in_calling,
        mute_mic: mute_mic,
      ),
      body: in_calling
          ? OrientationBuilder(
              builder: (context, orientation) {
                return Stack(
                  children: [
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(
                          0.0,
                          0.0,
                          0.0,
                          0.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                        ),
                        child: RTCVideoView(
                          remote_renderer,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20.0,
                      top: 20.0,
                      child: Container(
                        width: orientation == Orientation.portrait ? 90.0 : 120.0,
                        height: orientation == Orientation.portrait ? 120.0 : 90.0,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                        ),
                        child: RTCVideoView(
                          local_renderer,
                          mirror: true,
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : contact_list(),
    );
  }
}
