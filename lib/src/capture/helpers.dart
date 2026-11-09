import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../config/golden_capture_config.dart';

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

/// Calculates the size of the canvas that holds [screenCount] screens of
/// [screenWidth] x [screenHeight], arranged by [GoldenCaptureConfig.layoutType].
///
/// Shared by flow and animation captures so both honour the same layout.
Size calculateCanvasDimensions(
  int screenCount,
  double screenWidth,
  double screenHeight,
  GoldenCaptureConfig config,
) {
  const titleHeight = 40.0;
  const padding = 20.0;

  switch (config.layoutType) {
    case CaptureLayoutType.vertical:
      return Size(
        screenWidth + (padding * 2),
        (screenHeight + titleHeight + config.spacing) * screenCount + padding,
      );

    case CaptureLayoutType.horizontal:
      return Size(
        (screenWidth + config.spacing) * screenCount + padding,
        screenHeight + titleHeight + (padding * 2),
      );

    case CaptureLayoutType.grid:
      final rows = (screenCount / config.maxScreensPerRow).ceil();
      final cols = config.maxScreensPerRow;
      return Size(
        (screenWidth + config.spacing) * cols + padding,
        (screenHeight + titleHeight + config.spacing) * rows + padding,
      );
  }
}

/// Calculates the position of an image on the canvas.
Offset calculateImagePosition(
  int index,
  double screenWidth,
  double screenHeight,
  GoldenCaptureConfig config,
) {
  const titleHeight = 40.0;
  const padding = 20.0;

  switch (config.layoutType) {
    case CaptureLayoutType.vertical:
      return Offset(
        padding,
        padding + (screenHeight + titleHeight + config.spacing) * index,
      );

    case CaptureLayoutType.horizontal:
      return Offset(
        padding + (screenWidth + config.spacing) * index,
        padding,
      );

    case CaptureLayoutType.grid:
      final row = index ~/ config.maxScreensPerRow;
      final col = index % config.maxScreensPerRow;
      return Offset(
        padding + (screenWidth + config.spacing) * col,
        padding + (screenHeight + titleHeight + config.spacing) * row,
      );
  }
}
