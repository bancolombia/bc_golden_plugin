import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

class GoldenFlowConfig {
  const GoldenFlowConfig({
    required this.testName,
    this.delayBetweenScreens = const Duration(milliseconds: 100),
    this.layoutType = FlowLayoutType.grid,
    this.maxScreensPerRow = 3,
    this.spacing = 16.0,
    this.device,
  });

  final String testName;
  final Duration delayBetweenScreens;
  final FlowLayoutType layoutType;
  final int maxScreensPerRow;
  final double spacing;
  final WindowConfigData? device;
}

enum FlowLayoutType {
  vertical,
  horizontal,
  grid,
}

class FlowStep {
  const FlowStep({
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
