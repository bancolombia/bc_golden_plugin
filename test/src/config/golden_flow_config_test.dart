import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenCaptureConfig', () {
    test('should create with required parameters', () {
      const config = GoldenCaptureConfig(testName: 'test_flow');

      expect(config.testName, equals('test_flow'));
      expect(config.delayBetweenScreens,
          equals(const Duration(milliseconds: 100)));
      expect(config.layoutType, equals(CaptureLayoutType.grid));
      expect(config.maxScreensPerRow, equals(3));
      expect(config.spacing, equals(16.0));
      expect(config.device, isNull);
    });

    test('should create with custom parameters', () {
      final device = GoldenDeviceData.iPhone13;

      final config = GoldenCaptureConfig(
        testName: 'custom_flow',
        delayBetweenScreens: const Duration(milliseconds: 200),
        layoutType: CaptureLayoutType.vertical,
        maxScreensPerRow: 2,
        spacing: 24.0,
        device: device,
      );

      expect(config.testName, equals('custom_flow'));
      expect(config.delayBetweenScreens,
          equals(const Duration(milliseconds: 200)));
      expect(config.layoutType, equals(CaptureLayoutType.vertical));
      expect(config.maxScreensPerRow, equals(2));
      expect(config.spacing, equals(24.0));
      expect(config.device, equals(device));
    });

    test('should handle zero delay', () {
      const config = GoldenCaptureConfig(
        testName: 'zero_delay_flow',
        delayBetweenScreens: Duration.zero,
      );

      expect(config.delayBetweenScreens, equals(Duration.zero));
    });

    test('should handle negative spacing', () {
      const config = GoldenCaptureConfig(
        testName: 'negative_spacing_flow',
        spacing: -5.0,
      );

      expect(config.spacing, equals(-5.0));
    });

    test('should handle zero maxScreensPerRow', () {
      const config = GoldenCaptureConfig(
        testName: 'zero_max_flow',
        maxScreensPerRow: 0,
      );

      expect(config.maxScreensPerRow, equals(0));
    });

    test('should handle large maxScreensPerRow', () {
      const config = GoldenCaptureConfig(
        testName: 'large_max_flow',
        maxScreensPerRow: 100,
      );

      expect(config.maxScreensPerRow, equals(100));
    });
  });

  group('CaptureLayoutType', () {
    test('should have all expected values', () {
      expect(CaptureLayoutType.values, hasLength(3));
      expect(CaptureLayoutType.values, contains(CaptureLayoutType.vertical));
      expect(CaptureLayoutType.values, contains(CaptureLayoutType.horizontal));
      expect(CaptureLayoutType.values, contains(CaptureLayoutType.grid));
    });

    test('should have correct enum indices', () {
      expect(CaptureLayoutType.vertical.index, equals(0));
      expect(CaptureLayoutType.horizontal.index, equals(1));
      expect(CaptureLayoutType.grid.index, equals(2));
    });

    test('should have correct string representations', () {
      expect(CaptureLayoutType.vertical.toString(),
          equals('CaptureLayoutType.vertical'));
      expect(CaptureLayoutType.horizontal.toString(),
          equals('CaptureLayoutType.horizontal'));
      expect(
          CaptureLayoutType.grid.toString(), equals('CaptureLayoutType.grid'));
    });
  });

  group('GoldenStep', () {
    test('creates with required parameters', () {
      final step = GoldenStep(
        stepName: 'Test Step',
        widgetBuilder: () => Container(),
      );

      expect(step.stepName, equals('Test Step'));
      expect(step.widgetBuilder, isNotNull);
      expect(step.setupAction, isNull);
      expect(step.verifyAction, isNull);
    });

    test('creates with all parameters', () {
      Future<void> setupAction(WidgetTester tester) async {}
      Future<void> verifyAction(WidgetTester tester) async {}

      final step = GoldenStep(
        stepName: 'Complete Step',
        widgetBuilder: () => Container(),
        setupAction: setupAction,
        verifyAction: verifyAction,
      );

      expect(step.stepName, equals('Complete Step'));
      expect(step.widgetBuilder, isNotNull);
      expect(step.setupAction, equals(setupAction));
      expect(step.verifyAction, equals(verifyAction));
    });

    test('creates with partial optional parameters', () {
      Future<void> setupAction(WidgetTester tester) async {}

      final step = GoldenStep(
        stepName: 'Partial Step',
        widgetBuilder: () => Container(),
        setupAction: setupAction,
      );

      expect(step.stepName, equals('Partial Step'));
      expect(step.widgetBuilder, isNotNull);
      expect(step.setupAction, equals(setupAction));
      expect(step.verifyAction, isNull);
    });

    test('different steps are not equal', () {
      final step1 = GoldenStep(
        stepName: 'Step 1',
        widgetBuilder: () => Container(),
      );

      final step2 = GoldenStep(
        stepName: 'Step 2',
        widgetBuilder: () => Container(),
      );

      expect(step1, isNot(equals(step2)));
    });

    test('widgetBuilder returns correct widget', () {
      final widget = Container();
      final step = GoldenStep(
        stepName: 'Widget Test',
        widgetBuilder: () => widget,
      );

      final result = step.widgetBuilder();
      expect(result, equals(widget));
    });
  });
}
