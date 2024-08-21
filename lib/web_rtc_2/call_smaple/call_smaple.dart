// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/contact_list/model/contact.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/connect.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/contact_list.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/fab/fab_on_call.dart';
import 'package:xapptor_communication/web_rtc_2/call_smaple/fab/fab_out_of_call.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/invite.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/model/session.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/mute_mic.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/signaling.dart';
import 'package:xapptor_communication/web_rtc_2/signaling/call_line/subscribe_to_call_line.dart';

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
      'name': 'Javier Garcia',
      'user_agent': 'Flutter',
    },
    {
      'id': 'escUi2UnlINqYrpBzU5JL5M8GTk2',
      'name': 'Jesus Garcia',
      'user_agent': 'Flutter',
    },
  ];
  final RTCVideoRenderer local_renderer = RTCVideoRenderer();
  final RTCVideoRenderer remote_renderer = RTCVideoRenderer();
  bool in_calling = false;
  Session? _session;
  DesktopCapturerSource? desktop_capturer_selected_source;
  bool wait_accept = false;

  GlobalKey<ExpandableFabState> expandable_fab_key = GlobalKey<ExpandableFabState>();

  @override
  initState() {
    super.initState();
    init_renderers();
    connect(context);

    signaling?.subscribe_to_call_line(
      user_id: widget.user_id,
    );
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
        contact: Contact.empty(),
        media: 'video',
        use_screen: use_screen,
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: in_calling ? fab_on_call() : fab_out_of_call(),
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
