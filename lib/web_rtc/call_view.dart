import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:xapptor_communication/qr_generator.dart';
import 'package:xapptor_ui/screens/qr_scanner.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'signaling.dart';
import 'dart:ui' as ui;

class CallView extends StatefulWidget {
  CallView({
    required this.main_color,
    required this.background_color,
    required this.signaling,
    required this.local_renderer,
    required this.remote_renderer,
    required this.enable_audio,
    required this.enable_video,
    required this.text_list,
  });

  final Color main_color;
  final Color background_color;
  final Signaling signaling;
  final RTCVideoRenderer local_renderer;
  final RTCVideoRenderer remote_renderer;
  bool enable_audio = false;
  bool enable_video = false;
  final List<String> text_list;

  @override
  _CallViewState createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  TextEditingController room_id_controller = TextEditingController();

  String room_id = "";
  bool show_qr_scanner = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.local_renderer.dispose();
    widget.remote_renderer.dispose();
    super.dispose();
  }

  Future<ui.Image> get_qr_image(String src) async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load(src);
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;

    return show_qr_scanner
        ? QRScanner(
            descriptive_text: "Frame the QR code",
            update_qr_value: (new_value) {
              room_id_controller.text = new_value;
              show_qr_scanner = false;
              setState(() {});
            },
            border_color: widget.main_color,
            border_radius: 4,
            border_length: 40,
            border_width: 8,
            cut_out_size: 300,
            button_linear_gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.4),
                Colors.green.withOpacity(0.4),
              ],
            ),
            permission_message:
                "You must give the camera permission to capture QR codes",
            permission_message_no: "Cancel",
            permission_message_yes: "Accept",
            enter_code_text: "Enter your code",
            validate_button_text: "Validate",
            fail_message: "You have to enter a code",
            textfield_color: Colors.green,
            show_main_button: false,
            main_button_text: "Button",
            main_button_function: () => null,
          )
        : Container(
            color: widget.background_color,
            child: ListView(
              children: [
                SizedBox(height: 12),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          widget.signaling.open_user_media(
                            local_renderer: widget.local_renderer,
                            remote_renderer: widget.remote_renderer,
                            device_id: "",
                            enable_audio: widget.enable_audio,
                            enable_video: widget.enable_video,
                          );
                          setState(() {});
                        },
                        child: Text("Open camera & microphone"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          room_id = await widget.signaling
                              .create_room(widget.local_renderer);
                          room_id_controller.text = room_id;
                          setState(() {});
                        },
                        child: Text("Create room"),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add roomId
                          widget.signaling.join_room(
                            room_id_controller.text,
                            widget.remote_renderer,
                          );
                        },
                        child: Text("Join room"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.signaling
                              .hang_up(widget.local_renderer)
                              .then((value) {
                            room_id_controller.clear();
                          });
                        },
                        child: Text("Hangup"),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: screen_height / 1.8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Flex(
                      direction: portrait ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.orange,
                            child: RTCVideoView(
                              widget.local_renderer,
                              mirror: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.cyan,
                            child: RTCVideoView(
                              widget.remote_renderer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Join the following Room:",
                                  textAlign: TextAlign.left,
                                ),
                                IconButton(
                                  onPressed: () {
                                    show_qr_scanner = true;
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: widget.main_color,
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: room_id_controller,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: room_id_controller.text.isNotEmpty
                            ? FutureBuilder<ui.Image>(
                                future: get_qr_image("assets/images/logo.png"),
                                builder: (ctx, snapshot) {
                                  final size = 280.0;
                                  if (!snapshot.hasData) {
                                    return Container(width: size, height: size);
                                  }

                                  return qr_generator(room_id_controller.text);

                                  // return CustomPaint(
                                  //   size: Size(200, 200),
                                  //   painter: QrPainter(
                                  //     data: room_id_controller.text,
                                  //     version: QrVersions.auto,
                                  //     eyeStyle: const QrEyeStyle(
                                  //       eyeShape: QrEyeShape.square,
                                  //       color: Color(0xff128760),
                                  //     ),
                                  //     dataModuleStyle: const QrDataModuleStyle(
                                  //       dataModuleShape:
                                  //           QrDataModuleShape.square,
                                  //       color: Color(0xff1a5441),
                                  //     ),
                                  //     // embeddedImage: snapshot.data,
                                  //     // embeddedImageStyle: QrEmbeddedImageStyle(
                                  //     //   size: Size.square(60),
                                  //     // ),
                                  //   ),
                                  // );
                                },
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
