import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GoldenFlowConfig {
  const GoldenFlowConfig({
    required this.testName,
    this.deviceSize = const Size(375, 812),
    this.delayBetweenScreens = const Duration(milliseconds: 100),
    this.layoutType = FlowLayoutType.vertical,
    this.maxScreensPerRow = 2,
    this.spacing = 16.0,
  });

  final String testName;
  final Size deviceSize;
  final Duration delayBetweenScreens;
  final FlowLayoutType layoutType;
  final int maxScreensPerRow;
  final double spacing;
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
