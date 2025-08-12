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

    goldenFlowTest('renders flow and matches golden', steps, config);
  });
}
