import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<ui.Image> decodeImageBytes(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();

  return frame.image;
}

void drawBorder(
  Canvas canvas,
  Offset position,
  double screenWidth,
  double screenHeight,
) {
  canvas.drawRect(
    Rect.fromLTWH(position.dx, position.dy, screenWidth, screenHeight),
    Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
}
