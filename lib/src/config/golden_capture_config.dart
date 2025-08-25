import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

/// ## GoldenCaptureConfig
/// Configuration class for golden capture tests with multiple steps.
/// This class allows you to define the parameters for a series of golden tests,
/// including the test name, delay between screens, layout type, maximum screens per row,
/// spacing, and device configuration.
/// * [testName] The name of the test, used to identify the golden file.
/// * [delayBetweenScreens] The delay between rendering each screen in the capture.
/// * [layoutType] The layout type for displaying the screens in the capture.
///   - `vertical`: Screens are displayed vertically.
///   - `horizontal`: Screens are displayed horizontally.
///   - `grid`: Screens are displayed in a grid layout.
/// * [maxScreensPerRow] The maximum number of screens to display per row in grid layout.
/// * [spacing] The spacing between screens in the capture.
/// * [device] Optional device configuration for the golden test.
/// {@category Configuration}
class GoldenCaptureConfig {
  const GoldenCaptureConfig({
    required this.testName,
    this.delayBetweenScreens = const Duration(milliseconds: 100),
    this.layoutType = CaptureLayoutType.grid,
    this.maxScreensPerRow = 3,
    this.spacing = 16.0,
    this.device,
  });

  final String testName;
  final Duration delayBetweenScreens;
  final CaptureLayoutType layoutType;
  final int maxScreensPerRow;
  final double spacing;
  final WindowConfigData? device;
}

enum CaptureLayoutType {
  vertical,
  horizontal,
  grid,
}

/// ## GoldenStep
/// Represents a single step in a golden flow test.
///
/// This class encapsulates the details of each step, including the widget to be rendered,
/// the name of the step, and optional setup and verification actions.
/// * [stepName] The name of the step, used for identification in the flow.
/// * [widgetBuilder] A function that returns the widget to be rendered for this step.
/// * [setupAction] An optional function to perform setup actions before capturing the screenshot.
/// * [verifyAction] An optional function to perform verification actions after rendering the widget.
///
/// The `GoldenStep` class is used in conjunction with the `BcGoldenCapture.multiple` function to create a series of golden tests.
/// {@category Configuration}
class GoldenStep {
  const GoldenStep({
    required this.stepName,
    required this.widgetBuilder,
    this.setupAction,
    this.verifyAction,
  });

  final String stepName;
  final Widget Function() widgetBuilder;
  final Future<void> Function(WidgetTester)? setupAction;
  final Future<void> Function(WidgetTester)? verifyAction;
}
