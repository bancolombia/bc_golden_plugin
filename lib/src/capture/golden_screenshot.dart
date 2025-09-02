/// An extension on WidgetTester that handles capturing and managing golden screenshots.
///
/// This extension provides functionality to capture screenshots, add them to a collection,
/// crop images, and combine multiple screenshots into a single image. It also includes
/// methods for calculating canvas dimensions based on the layout configuration and
/// positioning images on the canvas.
///
/// ## Usage
/// To use the `GoldenScreenshot` extension, call its methods directly on a WidgetTester
/// instance within your tests.
///
/// ### Example
/// ```dart
/// testWidgets('My golden test', (tester) async {
///   await tester.captureGoldenScreenshot();
///
///   final combinedImage = await tester.combineGoldenScreenshots(
///     config,
///     stepNames,
///   );
/// });
/// ```
///
/// ## Methods
/// - `Future<Uint8List> captureGoldenScreenshot()`: Captures a screenshot of the current widget and returns it.
/// - `Future<Uint8List> combineGoldenScreenshots(GoldenCaptureConfig config, List<String> stepNames)`: Combines multiple screenshots into a single image.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../config/golden_capture_config.dart';
import '../helpers/logger.dart';

// Global storage for screenshots per test session
final Map<WidgetTester, List<Uint8List>> _screenshotStorage = {};

extension GoldenScreenshot on WidgetTester {
  /// Gets the list of captured screenshots for this tester instance.
  List<Uint8List> get goldenScreenshots => _screenshotStorage[this] ?? [];

  /// Captures a screenshot of the current widget and adds it to the collection.
  /// Returns the captured screenshot as Uint8List.
  Future<Uint8List> captureGoldenScreenshot() async {
    final RenderRepaintBoundary boundary = find
        .byElementPredicate(
          (element) => element.renderObject is RenderRepaintBoundary,
        )
        .evaluate()
        .first
        .renderObject as RenderRepaintBoundary;

    logDebug('[flows][captureScreenshot] Capturing screenshot...');

    final ui.Image image = boundary.toImageSync();

    logDebug(
      '[flows][captureScreenshot] Screenshot captured, converting to bytes...',
    );

    final ui.Image croppedImage = await _cropImageToSize(
      image,
      Offset.zero,
      Size(
        boundary.size.width,
        boundary.size.height,
      ),
    );

    logDebug('[flows][captureScreenshot] Screenshot cropped to size: '
        '${croppedImage.width}x${croppedImage.height}');

    final ByteData? byteData = await croppedImage
        .toByteData(
          format: ui.ImageByteFormat.png,
        )
        .timeout(
          const Duration(seconds: 2),
        );

    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to get byte data from image');
    }

    logDebug('[flows][captureScreenshot] Screenshot converted to bytes.');

    final screenshot = byteData.buffer.asUint8List();

    // Initialize the list if it doesn't exist
    _screenshotStorage[this] ??= <Uint8List>[];
    _screenshotStorage[this]!.add(screenshot);

    return screenshot;
  }

  /// Clears all captured screenshots for this tester instance.
  void clearGoldenScreenshots() {
    _screenshotStorage[this]?.clear();
  }

  /// Combines multiple screenshots into a single image.
  Future<Uint8List> combineGoldenScreenshots(
    GoldenCaptureConfig config,
    List<String> stepNames,
  ) async {
    final screenshots = goldenScreenshots;

    logDebug(
      '[flows][combineScreenshots] Starting combineScreenshots with ${screenshots.length} screenshots',
    );

    if (screenshots.isEmpty) {
      logError('No screenshots provided to combine');
      throw ArgumentError('No screenshots to combine');
    }

    try {
      logDebug(
        '[flows][combineScreenshots] Decoding first image to get dimensions...',
      );
      final firstImage =
          await _decodeImageBytes(screenshots.firstOrNull ?? Uint8List(0));

      final screenWidth = firstImage.width.toDouble();
      final screenHeight = firstImage.height.toDouble();

      logDebug(
        '[flows][combineScreenshots] Screen dimensions: ${screenWidth}x$screenHeight',
      );

      final canvasDimensions = _calculateCanvasDimensions(
        screenshots.length,
        screenWidth,
        screenHeight,
        config,
      );

      logDebug(
        '[flows][combineScreenshots] Canvas dimensions: ${canvasDimensions.width}x${canvasDimensions.height}',
      );

      const maxCanvasSize = 4096;
      final scaleFactor = canvasDimensions.width > maxCanvasSize ||
              canvasDimensions.height > maxCanvasSize
          ? maxCanvasSize /
              math.max(canvasDimensions.width, canvasDimensions.height)
          : 1.0;

      final finalWidth = (canvasDimensions.width * scaleFactor).toInt();
      final finalHeight = (canvasDimensions.height * scaleFactor).toInt();

      logDebug(
        '[flows][combineScreenshots] Final canvas size: ${finalWidth}x$finalHeight (scale: $scaleFactor)',
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, finalWidth.toDouble(), finalHeight.toDouble()),
        Paint()..color = Colors.white,
      );

      logDebug(
        '[flows][combineScreenshots] Drawing screenshots on canvas...',
      );

      for (int index = 0; index < screenshots.length; index++) {
        logDebug(
          '[flows][combineScreenshots] Processing screenshot ${index + 1}/${screenshots.length}',
        );

        try {
          final image = await _decodeImageBytes(screenshots[index]);
          final position = _calculateImagePosition(
            index,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
            config,
          );

          final srcRect = Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          );
          final dstRect = Rect.fromLTWH(
            position.dx,
            position.dy,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
          );

          canvas.drawImageRect(image, srcRect, dstRect, Paint());

          _drawStepTitle(
            canvas,
            stepNames[index],
            position,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
            scaleFactor,
          );

          _drawBorder(
            canvas,
            position,
            screenWidth * scaleFactor,
            screenHeight * scaleFactor,
          );

          image.dispose();
        } catch (e) {
          logError(
            '[flows][combineScreenshots] Error processing screenshot $index: $e',
          );
          rethrow;
        }
      }

      logDebug('[flows][combineScreenshots] Converting canvas to image...');

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(finalWidth, finalHeight);

      logDebug('[flows][combineScreenshots] Converting image to bytes...');

      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      finalImage.dispose();
      picture.dispose();

      if (byteData == null) {
        logError(
          '[flows][combineScreenshots] Failed to convert image to bytes',
        );
        throw Exception('Failed to convert image to bytes');
      }

      final result = byteData.buffer.asUint8List();
      logDebug(
        '[flows][combineScreenshots] ✓ Successfully combined screenshots. Final size: ${result.length} bytes',
      );

      return result;
    } catch (e) {
      logError('[flows][combineScreenshots] Error in combineScreenshots: $e');
      logError(
        '[flows][combineScreenshots] Stack trace: ${StackTrace.current}',
      );
      rethrow;
    }
  }

  /// Crops an image to the specified dimensions.
  Future<ui.Image> _cropImageToSize(
    ui.Image image,
    Offset topLeft,
    Size size,
  ) async {
    final top = topLeft.dy.round();
    final left = topLeft.dx.round();
    final width = size.width.round();
    final height = size.height.round();

    logDebug('[flows][_cropImage] Cropping image: '
        'top: $top, left: $left, width: $width, height: $height');

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception('Failed to get byte data from image');
    }

    const bytesPerPixel = 4;
    final originalBytes = byteData.buffer.asUint8List();
    final originalWidth = image.width;
    final croppedBytes = Uint8List(width * height * bytesPerPixel);

    logDebug('[flows][_cropImage] Creating cropped bytes buffer: '
        '${croppedBytes.length} bytes');

    for (int row = 0; row < height; row++) {
      final srcStart = ((top + row) * originalWidth + left) * bytesPerPixel;
      final destStart = row * width * bytesPerPixel;
      croppedBytes.setRange(
        destStart,
        destStart + width * bytesPerPixel,
        originalBytes,
        srcStart,
      );
    }

    logDebug('[flows][_cropImage] Cropped bytes created successfully.');

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      croppedBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete as ui.ImageDecoderCallback,
    );

    logDebug('[flows][_cropImage] Decoding cropped image from pixels...');
    return completer.future;
  }

  /// Decodes an image from byte data.
  Future<ui.Image> _decodeImageBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Calculates the dimensions of the canvas based on layout configuration.
  Size _calculateCanvasDimensions(
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
  Offset _calculateImagePosition(
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

  /// Draws the step title on the canvas.
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
          fontFamily: 'Roboto-Regular',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: screenWidth);

    // Background for the text
    canvas.drawRect(
      Rect.fromLTWH(
        position.dx,
        position.dy + screenHeight,
        screenWidth,
        30 * scaleFactor,
      ),
      Paint()..color = Colors.grey.shade100,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(
        position.dx + 8 * scaleFactor,
        position.dy + screenHeight + 8 * scaleFactor,
      ),
    );

    textPainter.dispose();
  }

  /// Draws a border around the screenshot.
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
