import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

Future<Map> get_turn_credential(
  String host,
  int port,
) async {
  HttpClient client = HttpClient(context: SecurityContext());
  client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    debugPrint('getTurnCredential: Allow self-signed certificate => $host:$port. ');
    return true;
  };
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  var response_body = await response.transform(const Utf8Decoder()).join();
  debugPrint('getTurnCredential:response => $response_body.');
  Map data = const JsonDecoder().convert(response_body);
  return data;
}
