// ignore_for_file: prefer-match-file-name
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_capture_config.dart';

/// ## GoldenAnimationStep
/// Represents a specific frame in an animation timeline to be captured.
///
/// This class defines when to capture a frame during an animation and allows
/// for optional setup and verification actions at that specific timestamp.
///
/// * [timestamp] The exact time in the animation when this frame should be captured in ms.
/// * [frameName] A descriptive name for this frame (e.g., "start", "peak", "end").
/// * [setupAction] Optional function to execute before capturing this frame.
/// * [verifyAction] Optional function to verify the state after capturing this frame.
///
/// {@category Configuration}
class GoldenAnimationStep {
  const GoldenAnimationStep({
    required this.timestamp,
    required this.frameName,
    this.setupAction,
    this.verifyAction,
  });

  final Duration timestamp;
  final String frameName;
  final Future<void> Function(WidgetTester)? setupAction;
  final Future<void> Function(WidgetTester)? verifyAction;
}

/// ## GoldenAnimationConfig
/// Configuration class for capturing golden tests of animations.
///
/// This class extends `GoldenCaptureConfig` to provide animation-specific
/// configuration options including timeline settings and frame capture details.
///
/// * [testName] The name of the test, used to identify the golden file.
/// * [totalDuration] The total duration of the animation to be tested.
/// * [animationSteps] List of specific frames to capture during the animation.
/// * [showTimelineLabels] Whether to display timestamp labels on the combined image.
/// * [timelineColor] Color for the timeline visualization in the golden image.
/// * [layoutType] How to arrange the captured frames (vertical, horizontal, grid).
/// * [maxScreensPerRow] Maximum frames per row when using grid layout.
/// * [spacing] Space between frames in the combined image.
/// * [device] Optional device configuration for consistent rendering.
///
/// {@category Configuration}
class GoldenAnimationConfig extends GoldenCaptureConfig {
  const GoldenAnimationConfig({
    required super.testName,
    required this.totalDuration,
    required this.animationSteps,
    this.showTimelineLabels = true,
    this.timelineColor = Colors.blue,
    super.layoutType = CaptureLayoutType.horizontal,
    super.maxScreensPerRow = 5,
    super.spacing = 24.0,
    super.device,
  });

  final Duration totalDuration;
  final List<GoldenAnimationStep> animationSteps;
  final bool showTimelineLabels;
  final Color timelineColor;

  /// Validates that all animation steps are within the total duration.
  bool get isValid {
    return animationSteps.every(
      (step) => step.timestamp <= totalDuration,
    );
  }

  /// Gets the animation steps sorted by timestamp.
  List<GoldenAnimationStep> get sortedSteps {
    final steps = List<GoldenAnimationStep>.from(animationSteps);
    steps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return steps;
  }
}
