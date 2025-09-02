// ignore_for_file: avoid-ignoring-return-values, avoid-non-null-assertion

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../config/golden_animation_config.dart';
import '../helpers/logger.dart';
import 'golden_screenshot.dart';

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
  Future<Uint8List> captureAnimation({
    required Widget widget,
    required GoldenAnimationConfig config,
    Future<void> Function(WidgetTester)? animationSetup,
  }) async {
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

    // Clear any previous captures
    clearGoldenScreenshots();

    // Pump the widget
    await pumpWidget(widget);

    // Execute animation setup if provided
    if (animationSetup != null) {
      await animationSetup(this);
    }

    // Sort steps by timestamp to ensure proper order
    final sortedSteps = config.sortedSteps;

    Duration previousTimestamp = Duration.zero;

    for (int i = 0; i < sortedSteps.length; i++) {
      final step = sortedSteps[i];
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
    final stepNames = sortedSteps.map((step) => step.frameName).toList();

    // Combine all captured frames into a single image using the extension
    final combinedImage = await combineGoldenScreenshots(
      config,
      stepNames,
    );

    logDebug('[animation] Animation capture completed successfully');

    return combinedImage;
  }
}
