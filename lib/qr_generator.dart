import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

Widget qr_generator(String code) {
  final qr_code = QrCode(4, QrErrorCorrectLevel.L)..addData(code);
  final qr_image = QrImage(qr_code);

  final squares = <bool>[];

  for (var x = 0; x < qr_image.moduleCount; x++) {
    for (var y = 0; y < qr_image.moduleCount; y++) {
      if (qr_image.isDark(y, x)) {
        squares.add(qr_image.isDark(y, x));
      }
    }
  }

  return GridView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: qr_image.moduleCount,
      crossAxisSpacing: 5.0,
      mainAxisSpacing: 5.0,
    ),
    itemCount: qr_image.moduleCount,
    itemBuilder: (context, index) {
      return Container(
        color: squares[index] ? Colors.blue : Colors.white,
      );
    },
  );
}
