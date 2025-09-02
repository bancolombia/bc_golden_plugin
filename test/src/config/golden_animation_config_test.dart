import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenAnimationConfig', () {
    test('should validate animation steps within total duration', () {
      const config = GoldenAnimationConfig(
        testName: 'test_animation',
        totalDuration: Duration(milliseconds: 500),
        animationSteps: [
          GoldenAnimationStep(
            timestamp: Duration.zero,
            frameName: 'start',
          ),
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 250),
            frameName: 'middle',
          ),
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 500),
            frameName: 'end',
          ),
        ],
      );

      expect(config.isValid, isTrue);
    });

    test('should invalidate animation steps beyond total duration', () {
      const config = GoldenAnimationConfig(
        testName: 'test_animation',
        totalDuration: Duration(milliseconds: 500),
        animationSteps: [
          GoldenAnimationStep(
            timestamp: Duration.zero,
            frameName: 'start',
          ),
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 600), // Beyond totalDuration
            frameName: 'invalid',
          ),
        ],
      );

      expect(config.isValid, isFalse);
    });

    test('should sort animation steps by timestamp', () {
      const config = GoldenAnimationConfig(
        testName: 'test_animation',
        totalDuration: Duration(milliseconds: 500),
        animationSteps: [
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 300),
            frameName: 'third',
          ),
          GoldenAnimationStep(
            timestamp: Duration.zero,
            frameName: 'first',
          ),
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 150),
            frameName: 'second',
          ),
        ],
      );

      final sortedSteps = config.sortedSteps;

      expect(sortedSteps[0].frameName, equals('first'));
      expect(sortedSteps[1].frameName, equals('second'));
      expect(sortedSteps[2].frameName, equals('third'));
    });

    test('should have correct default values', () {
      const config = GoldenAnimationConfig(
        testName: 'test_animation',
        totalDuration: Duration(milliseconds: 500),
        animationSteps: [],
      );

      expect(config.showTimelineLabels, isTrue);
      expect(config.timelineColor, equals(Colors.blue));
      expect(config.layoutType, equals(CaptureLayoutType.horizontal));
      expect(config.maxScreensPerRow, equals(5));
      expect(config.spacing, equals(24.0));
    });
  });

  group('GoldenAnimationStep', () {
    test('should create step with required parameters', () {
      const step = GoldenAnimationStep(
        timestamp: Duration(milliseconds: 100),
        frameName: 'test_frame',
      );

      expect(step.timestamp, equals(const Duration(milliseconds: 100)));
      expect(step.frameName, equals('test_frame'));
      expect(step.setupAction, isNull);
      expect(step.verifyAction, isNull);
    });

    test('should create step with optional actions', () {
      Future<void> mockSetupAction(WidgetTester tester) async {}
      Future<void> mockVerifyAction(WidgetTester tester) async {}

      final step = GoldenAnimationStep(
        timestamp: const Duration(milliseconds: 100),
        frameName: 'test_frame',
        setupAction: mockSetupAction,
        verifyAction: mockVerifyAction,
      );

      expect(step.setupAction, isNotNull);
      expect(step.verifyAction, isNotNull);
    });
  });

  group('GoldenAnimationCapture', () {
    testWidgets('should throw error for invalid configuration', (tester) async {
      const invalidConfig = GoldenAnimationConfig(
        testName: 'test_animation',
        totalDuration: Duration(milliseconds: 100),
        animationSteps: [
          GoldenAnimationStep(
            timestamp: Duration(milliseconds: 200), // Beyond totalDuration
            frameName: 'invalid',
          ),
        ],
      );

      expect(
        () async => await tester.captureAnimation(
          widget: const SizedBox(),
          config: invalidConfig,
        ),
        throwsArgumentError,
      );
    });
  });
}
