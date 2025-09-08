// ignore_for_file: avoid-ignoring-return-values, avoid-non-null-assertion

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../config/golden_animation_config.dart';
import '../config/golden_capture_config.dart';
import '../helpers/logger.dart';
import 'golden_screenshot.dart';
import 'helpers.dart';

/// ## GoldenAnimationCapture
/// Extension on WidgetTester for capturing golden tests of Flutter animations.
///
/// This extension provides functionality to capture multiple frames of an animation
/// at specific timestamps, creating a comprehensive visual test that shows
/// the animation's progression over time.
///
/// ## Usage
/// ```dart
/// await tester.captureAnimation(
///   widget: MyAnimatedWidget(),
///   config: GoldenAnimationConfig(
///     testName: 'button_bounce_animation',
///     totalDuration: Duration(milliseconds: 500),
///     animationSteps: [
///       GoldenAnimationStep(
///         timestamp: Duration(milliseconds: 0),
///         frameName: 'start',
///       ),
///       GoldenAnimationStep(
///         timestamp: Duration(milliseconds: 250),
///         frameName: 'peak',
///       ),
///       GoldenAnimationStep(
///         timestamp: Duration(milliseconds: 500),
///         frameName: 'end',
///       ),
///     ],
///   ),
///   animationSetup: (tester) async {
///     // Optional setup code
///   },
/// );
/// ```
extension GoldenAnimationCapture on WidgetTester {
  /// Captures an animation by taking screenshots at specified timestamps.
  ///
  /// This method pumps the widget, starts the animation, and captures frames
  /// at the timestamps defined in the configuration.
  ///
  /// * [widget] The animated widget to test.
  /// * [config] Configuration containing animation steps and settings.
  /// * [animationSetup] Optional function to set up the animation before starting.
  ///
  /// Returns the combined image containing all captured frames.
  Future<Uint8List> captureAnimation(
    Widget widget,
    GoldenAnimationConfig config,
    Future<void> Function(WidgetTester)? animationSetup,
  ) async {
    if (!config.isValid) {
      throw ArgumentError(
        'Animation configuration is invalid. All steps must be within totalDuration.',
      );
    }

    logDebug('[animation] Starting animation capture for: ${config.testName}');
    logDebug(
      '[animation] Total duration: ${config.totalDuration.inMilliseconds}ms',
    );
    logDebug('[animation] Steps count: ${config.animationSteps.length}');

    clearGoldenScreenshots();

    await pumpWidget(widget);

    if (animationSetup != null) {
      await animationSetup(this);
    }

    final sortedSteps = config.sortedSteps;

    Duration previousTimestamp = Duration.zero;

    for (int index = 0; index < sortedSteps.length; index++) {
      final step = sortedSteps[index];
      final timeDiff = step.timestamp - previousTimestamp;

      logDebug(
        '[animation] Capturing frame at ${step.timestamp.inMilliseconds}ms: ${step.frameName}',
      );

      // Pump to the specific timestamp
      if (timeDiff > Duration.zero) {
        await pump(timeDiff);
      }

      // Execute setup action for this step if provided
      if (step.setupAction != null) {
        await step.setupAction!(this);
      }

      // Capture the frame using the extension
      await captureGoldenScreenshot();

      // Execute verification action for this step if provided
      if (step.verifyAction != null) {
        await step.verifyAction!(this);
      }

      previousTimestamp = step.timestamp;
    }

    logDebug('[animation] Combining ${goldenScreenshots.length} frames');

    // Create step names for the combined image
    final stepNames = sortedSteps
        .map(
          (step) => '${step.frameName} - ${step.timestamp.toString()}',
        )
        .toList();

    // Combine all captured frames into a single image using the extension
    final combinedImage = await combineAnimationScreenshots(
      config,
      stepNames,
    );

    logDebug('[animation] Animation capture completed successfully');

    return combinedImage;
  }

  Future<Uint8List> combineAnimationScreenshots(
    GoldenAnimationConfig config,
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
          await decodeImageBytes(screenshots.firstOrNull ?? Uint8List(0));

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
          final image = await decodeImageBytes(screenshots[index]);
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

          drawBorder(
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

  Size _calculateCanvasDimensions(
    int screenCount,
    double screenWidth,
    double screenHeight,
    GoldenAnimationConfig config,
  ) {
    const titleHeight = 40.0;
    const padding = 20.0;

    if (screenCount > 5) {
      final rows = (screenCount / config.maxScreensPerRow).ceil();
      final cols = config.maxScreensPerRow;

      return Size(
        (screenWidth + config.spacing) * cols + padding,
        (screenHeight + titleHeight + config.spacing) * rows + padding,
      );
    }

    return Size(
      (screenWidth + config.spacing) * screenCount + padding,
      screenHeight + titleHeight + (padding * 2),
    );
  }

  Offset _calculateImagePosition(
    int index,
    double screenWidth,
    double screenHeight,
    GoldenCaptureConfig config,
  ) {
    const padding = 20.0;
    const titleHeight = 40.0;

    if (index >= 5) {
      final row = (index / config.maxScreensPerRow).floor();
      final col = index % config.maxScreensPerRow;

      return Offset(
        padding + (screenWidth + config.spacing) * col,
        padding + (screenHeight + titleHeight + config.spacing) * row,
      );
    }

    return Offset(
      padding + (screenWidth + config.spacing) * index,
      padding,
    );
  }
}
