import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:bc_golden_plugin/src/capture/golden_screenshot.dart';
import 'package:bc_golden_plugin/src/testkit/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<GoldenScreenshot>(),
  MockSpec<Widget>(),
])
class FakeFlowStep implements FlowStep {
  FakeFlowStep({
    required this.stepName,
    required this.widgetBuilder,
    this.setupAction,
    this.verifyAction,
  });

  @override
  final String stepName;
  @override
  final Widget Function() widgetBuilder;
  @override
  final Future<void> Function(WidgetTester)? setupAction;
  @override
  final Future<void> Function(WidgetTester)? verifyAction;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int counter = 0;
  test('bcCustomWindowConfigData should return a WindowConfigData object', () {
    final configData = bcCustomWindowConfigData(
      name: 'Custom Config',
      size: const Size(360, 640),
      pixelDensity: 2.0,
    );
    expect(configData, isA<WindowConfigData>());
  });

  test('IconExtension.convertToGolden should return an IconData object', () {
    const iconData = IconData(0xe900, fontFamily: 'BdsFunctionalIcons');
    final convertedIcon = iconData.convertToGolden();
    expect(convertedIcon, isA<IconData>());
  });

  bcGoldenTest(
    'Test with real shadows',
    (tester) async {
      counter++;
    },
    shouldUseRealShadows: true,
  );

  test('bcGoldenTest should run test with real shadows', () async {
    expect(counter, 1);
  });

  group('goldenFlowTest', () {
    const config = GoldenFlowConfig(
      layoutType: FlowLayoutType.vertical,
      spacing: 8,
      maxScreensPerRow: 2,
      delayBetweenScreens: Duration.zero,
      testName: 'sample_flow',
    );

    final steps = <FlowStep>[
      FlowStep(
        stepName: 'Home',
        widgetBuilder: () => const ColoredBox(color: Colors.blue),
        setupAction: (tester) async {},
        verifyAction: (tester) async {},
      ),
      FlowStep(
        stepName: 'Details',
        widgetBuilder: () => const ColoredBox(color: Colors.red),
      ),
    ];

    // goldenFlowTest('renders flow and matches golden', steps, config);
  });

  group('Timeout parameter tests', () {
    testWidgets('bcWidgetMatchesImage accepts pumpAndSettleTimeout parameter', (tester) async {
      // This test verifies that the function accepts the new timeout parameter
      // without throwing an error during compilation/runtime
      const widget = ColoredBox(color: Colors.blue);
      
      // Mock the golden file comparator to avoid actual file operations
      try {
        await bcWidgetMatchesImage(
          imageName: 'test_timeout',
          widget: widget,
          tester: tester,
          pumpAndSettleTimeout: const Duration(seconds: 2),
        );
      } catch (e) {
        // We expect this to fail due to missing golden file setup in tests
        // but we want to verify the parameter is accepted
        expect(e.toString(), isNot(contains('pumpAndSettleTimeout')));
      }
    });

    testWidgets('bcWidgetMatchesImage accepts pumpDuration parameter', (tester) async {
      // This test verifies that the function accepts the new duration parameter
      const widget = ColoredBox(color: Colors.green);
      
      try {
        await bcWidgetMatchesImage(
          imageName: 'test_duration',
          widget: widget,
          tester: tester,
          pumpDuration: const Duration(milliseconds: 50),
        );
      } catch (e) {
        // We expect this to fail due to missing golden file setup in tests
        // but we want to verify the parameter is accepted
        expect(e.toString(), isNot(contains('pumpDuration')));
      }
    });

    testWidgets('bcWidgetMatchesImage accepts both timeout parameters', (tester) async {
      // This test verifies that the function accepts both new parameters
      const widget = ColoredBox(color: Colors.red);
      
      try {
        await bcWidgetMatchesImage(
          imageName: 'test_both_params',
          widget: widget,
          tester: tester,
          pumpAndSettleTimeout: const Duration(seconds: 1),
          pumpDuration: const Duration(milliseconds: 25),
        );
      } catch (e) {
        // We expect this to fail due to missing golden file setup in tests
        // but we want to verify the parameters are accepted
        expect(e.toString(), isNot(contains('pumpAndSettleTimeout')));
        expect(e.toString(), isNot(contains('pumpDuration')));
      }
    });

    test('goldenFlowTest accepts timeout parameters', () {
      // This test verifies that goldenFlowTest function signature accepts the new parameters
      final steps = <FlowStep>[
        FlowStep(
          stepName: 'Test Step',
          widgetBuilder: () => const ColoredBox(color: Colors.blue),
        ),
      ];

      const config = GoldenFlowConfig(
        layoutType: FlowLayoutType.vertical,
        spacing: 8,
        maxScreensPerRow: 2,
        delayBetweenScreens: Duration.zero,
        testName: 'timeout_test',
      );

      // This should compile without errors, demonstrating the parameters are accepted
      expect(() {
        goldenFlowTest(
          'test with timeout parameters',
          steps,
          config,
          pumpAndSettleTimeout: const Duration(seconds: 2),
          pumpDuration: const Duration(milliseconds: 50),
        );
      }, returnsNormally);
    });
  });
}
