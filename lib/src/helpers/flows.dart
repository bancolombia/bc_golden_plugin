import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../models/golden_flow_config.dart';

extension Flows on WidgetTester {
  Future<Uint8List> captureScreenshot() async {
    final RenderRepaintBoundary boundary = find
        .byElementPredicate(
          (element) => element.renderObject is RenderRepaintBoundary,
        )
        .evaluate()
        .first
        .renderObject as RenderRepaintBoundary;

    if (boundary == null) {
      throw Exception(
        'No RepaintBoundary found. Wrap your widget with RepaintBoundary.',
      );
    }

    debugPrint('Capturing screenshot...');

    final ui.Image image = await boundary.toImage(
      pixelRatio: view.devicePixelRatio,
    );

    debugPrint('Screenshot captured, converting to bytes...');

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    debugPrint('Screenshot converted to bytes.');

    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> combineScreenshots(
    List<Uint8List> screenshots,
    GoldenFlowConfig config,
    List<String> stepNames,
  ) async {
    debugPrint(
        'Starting combineScreenshots with ${screenshots.length} screenshots');

    if (screenshots.isEmpty) {
      throw ArgumentError('No screenshots to combine');
    }

    try {
      // Decodificar la primera imagen para obtener dimensiones
      debugPrint('Decoding first image to get dimensions...');
      final firstImage = await _decodeImage(screenshots.first);
      final screenWidth = firstImage.width.toDouble();
      final screenHeight = firstImage.height.toDouble();

      debugPrint('Screen dimensions: ${screenWidth}x${screenHeight}');

      // Calcular dimensiones del canvas final
      final canvasDimensions = _calculateCanvasDimensions(
        screenshots.length,
        screenWidth,
        screenHeight,
        config,
      );

      debugPrint(
          'Canvas dimensions: ${canvasDimensions.width}x${canvasDimensions.height}');

      // Crear el canvas con un límite de tamaño razonable
      final maxCanvasSize =
          4096; // Límite de tamaño para evitar problemas de memoria
      final scaleFactor = canvasDimensions.width > maxCanvasSize ||
              canvasDimensions.height > maxCanvasSize
          ? maxCanvasSize /
              math.max(canvasDimensions.width, canvasDimensions.height)
          : 1.0;

      final finalWidth = (canvasDimensions.width * scaleFactor).toInt();
      final finalHeight = (canvasDimensions.height * scaleFactor).toInt();

      debugPrint(
          'Final canvas size: ${finalWidth}x${finalHeight} (scale: $scaleFactor)');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Fondo blanco
      canvas.drawRect(
        Rect.fromLTWH(0, 0, finalWidth.toDouble(), finalHeight.toDouble()),
        Paint()..color = Colors.white,
      );

      debugPrint('Drawing screenshots on canvas...');

      // Procesar cada screenshot
      for (int i = 0; i < screenshots.length; i++) {
        debugPrint('Processing screenshot ${i + 1}/${screenshots.length}');

        try {
          final image = await _decodeImage(screenshots[i]);
          final position = _calculateImagePosition(
            i,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
            config,
          );

          // Dibujar la imagen escalada
          final srcRect = Rect.fromLTWH(
              0, 0, image.width.toDouble(), image.height.toDouble());
          final dstRect = Rect.fromLTWH(
            position.dx,
            position.dy,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
          );

          canvas.drawImageRect(image, srcRect, dstRect, Paint());

          // Dibujar el título del paso
          _drawStepTitle(
            canvas,
            stepNames[i],
            position,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
            scaleFactor,
          );

          // Dibujar borde
          _drawBorder(
            canvas,
            position,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
          );

          // Liberar memoria de la imagen
          image.dispose();
        } catch (e) {
          debugPrint('Error processing screenshot $i: $e');
          rethrow;
        }
      }

      debugPrint('Converting canvas to image...');

      // Convertir a imagen con manejo de errores
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(finalWidth, finalHeight);

      debugPrint('Converting image to bytes...');

      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // Limpiar recursos
      finalImage.dispose();
      picture.dispose();

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final result = byteData.buffer.asUint8List();
      debugPrint(
          '✓ Successfully combined screenshots. Final size: ${result.length} bytes');

      return result;
    } catch (e) {
      debugPrint('Error in combineScreenshots: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Size _calculateCanvasDimensions(
    int screenCount,
    double screenWidth,
    double screenHeight,
    GoldenFlowConfig config,
  ) {
    const titleHeight = 40.0;
    const padding = 20.0;

    switch (config.layoutType) {
      case FlowLayoutType.vertical:
        return Size(
          screenWidth + (padding * 2),
          (screenHeight + titleHeight + config.spacing) * screenCount + padding,
        );

      case FlowLayoutType.horizontal:
        return Size(
          (screenWidth + config.spacing) * screenCount + padding,
          screenHeight + titleHeight + (padding * 2),
        );

      case FlowLayoutType.grid:
        final rows = (screenCount / config.maxScreensPerRow).ceil();
        final cols = config.maxScreensPerRow;
        return Size(
          (screenWidth + config.spacing) * cols + padding,
          (screenHeight + titleHeight + config.spacing) * rows + padding,
        );
    }
  }

  Offset _calculateImagePosition(
    int index,
    double screenWidth,
    double screenHeight,
    GoldenFlowConfig config,
  ) {
    const titleHeight = 40.0;
    const padding = 10.0;

    switch (config.layoutType) {
      case FlowLayoutType.vertical:
        return Offset(
          padding,
          padding + (screenHeight + titleHeight + config.spacing) * index,
        );

      case FlowLayoutType.horizontal:
        return Offset(
          padding + (screenWidth + config.spacing) * index,
          padding,
        );

      case FlowLayoutType.grid:
        final row = index ~/ config.maxScreensPerRow;
        final col = index % config.maxScreensPerRow;
        return Offset(
          padding + (screenWidth + config.spacing) * col,
          padding + (screenHeight + titleHeight + config.spacing) * row,
        );
    }
  }

  void _drawStepTitle(
    Canvas canvas,
    String title,
    Offset position,
    double screenWidth,
    double screenHeight,
    double scaleFactor,
  ) {
    final fontSize = math.max(10.0, 14.0 * scaleFactor);

    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: screenWidth);

    // Fondo para el texto
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx,
        position.dy + screenHeight,
        screenWidth,
        30 * scaleFactor,
      ),
      Paint()..color = Colors.grey.shade100,
    );

    // Texto
    textPainter.paint(
      canvas,
      Offset(
        position.dx + 8 * scaleFactor,
        position.dy + screenHeight + 8 * scaleFactor,
      ),
    );

    textPainter.dispose();
  }

  void _drawBorder(
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
}
