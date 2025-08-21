import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenFlowConfig', () {
    test('should create with required parameters', () {
      const config = GoldenFlowConfig(testName: 'test_flow');

      expect(config.testName, equals('test_flow'));
      expect(config.delayBetweenScreens,
          equals(const Duration(milliseconds: 100)));
      expect(config.layoutType, equals(FlowLayoutType.grid));
      expect(config.maxScreensPerRow, equals(3));
      expect(config.spacing, equals(16.0));
      expect(config.device, isNull);
    });

    test('should create with custom parameters', () {
      final device = GoldenDeviceData.iPhone13;

      final config = GoldenFlowConfig(
        testName: 'custom_flow',
        delayBetweenScreens: const Duration(milliseconds: 200),
        layoutType: FlowLayoutType.vertical,
        maxScreensPerRow: 2,
        spacing: 24.0,
        device: device,
      );

      expect(config.testName, equals('custom_flow'));
      expect(config.delayBetweenScreens,
          equals(const Duration(milliseconds: 200)));
      expect(config.layoutType, equals(FlowLayoutType.vertical));
      expect(config.maxScreensPerRow, equals(2));
      expect(config.spacing, equals(24.0));
      expect(config.device, equals(device));
    });

    test('should handle zero delay', () {
      const config = GoldenFlowConfig(
        testName: 'zero_delay_flow',
        delayBetweenScreens: Duration.zero,
      );

      expect(config.delayBetweenScreens, equals(Duration.zero));
    });

    test('should handle negative spacing', () {
      const config = GoldenFlowConfig(
        testName: 'negative_spacing_flow',
        spacing: -5.0,
      );

      expect(config.spacing, equals(-5.0));
    });

    test('should handle zero maxScreensPerRow', () {
      const config = GoldenFlowConfig(
        testName: 'zero_max_flow',
        maxScreensPerRow: 0,
      );

      expect(config.maxScreensPerRow, equals(0));
    });

    test('should handle large maxScreensPerRow', () {
      const config = GoldenFlowConfig(
        testName: 'large_max_flow',
        maxScreensPerRow: 100,
      );

      expect(config.maxScreensPerRow, equals(100));
    });
  });

  group('FlowLayoutType', () {
    test('should have all expected values', () {
      expect(FlowLayoutType.values, hasLength(3));
      expect(FlowLayoutType.values, contains(FlowLayoutType.vertical));
      expect(FlowLayoutType.values, contains(FlowLayoutType.horizontal));
      expect(FlowLayoutType.values, contains(FlowLayoutType.grid));
    });

    test('should have correct enum indices', () {
      expect(FlowLayoutType.vertical.index, equals(0));
      expect(FlowLayoutType.horizontal.index, equals(1));
      expect(FlowLayoutType.grid.index, equals(2));
    });

    test('should have correct string representations', () {
      expect(FlowLayoutType.vertical.toString(),
          equals('FlowLayoutType.vertical'));
      expect(FlowLayoutType.horizontal.toString(),
          equals('FlowLayoutType.horizontal'));
      expect(FlowLayoutType.grid.toString(), equals('FlowLayoutType.grid'));
    });
  });

  group('FlowStep', () {
    test('should create with required parameters', () {
      final step = FlowStep(
        stepName: 'test_step',
        widgetBuilder: () => const Text('Test'),
      );

      expect(step.stepName, equals('test_step'));
      expect(step.widgetBuilder(), isA<Text>());
      expect(step.setupAction, isNull);
      expect(step.verifyAction, isNull);
    });

    test('should create with all parameters', () {
      Widget widgetBuilder() => Container();
      Future<void> setupAction(WidgetTester tester) async {}
      Future<void> verifyAction(WidgetTester tester) async {}

      final step = FlowStep(
        stepName: 'complete_step',
        widgetBuilder: widgetBuilder,
        setupAction: setupAction,
        verifyAction: verifyAction,
      );

      expect(step.stepName, equals('complete_step'));
      expect(step.widgetBuilder(), isA<Container>());
      expect(step.setupAction, isNotNull);
      expect(step.verifyAction, isNotNull);
    });

    test('should handle complex widget builders', () {
      final step = FlowStep(
        stepName: 'complex_step',
        widgetBuilder: () => MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Complex Widget')),
          ),
        ),
      );

      expect(step.stepName, equals('complex_step'));
      expect(step.widgetBuilder(), isA<MaterialApp>());
    });

    test('should handle empty step name', () {
      final step = FlowStep(
        stepName: '',
        widgetBuilder: () => const SizedBox(),
      );

      expect(step.stepName, isEmpty);
      expect(step.widgetBuilder(), isA<SizedBox>());
    });

    test('should handle widget builder that returns different types', () {
      final step1 = FlowStep(
        stepName: 'step1',
        widgetBuilder: () => const Icon(Icons.home),
      );

      final step2 = FlowStep(
        stepName: 'step2',
        widgetBuilder: () => const CircularProgressIndicator(),
      );

      expect(step1.widgetBuilder(), isA<Icon>());
      expect(step2.widgetBuilder(), isA<CircularProgressIndicator>());
    });

    testWidgets('should handle setup and verify actions with WidgetTester',
        (tester) async {
      bool setupCalled = false;
      bool verifyCalled = false;

      final step = FlowStep(
        stepName: 'action_step',
        widgetBuilder: () => const Text('Test'),
        setupAction: (tester) async {
          setupCalled = true;
        },
        verifyAction: (tester) async {
          verifyCalled = true;
        },
      );

      await step.setupAction?.call(tester);
      await step.verifyAction?.call(tester);

      expect(setupCalled, isTrue);
      expect(verifyCalled, isTrue);
    });
  });
}
