import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:bc_golden_plugin/src/testkit/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<Widget>(),
])
class FakeGoldenStep implements GoldenStep {
  FakeGoldenStep({
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

  BcGoldenCapture.single(
    'Test with real shadows',
    (tester) async {
      counter++;
    },
    shouldUseRealShadows: true,
  );

  test('BcGoldenCapture.single should run test with real shadows', () async {
    expect(counter, 1);
  });

  // Test backward compatibility with deprecated functions
  bcGoldenTest(
    'Test deprecated bcGoldenTest (backward compatibility)',
    (tester) async {
      counter++;
    },
    shouldUseRealShadows: true,
  );

  test('Deprecated bcGoldenTest should still work', () async {
    expect(counter, 2);
  });

  group('BcGoldenCapture.multiple', () {
    const config = GoldenCaptureConfig(
      layoutType: CaptureLayoutType.vertical,
      spacing: 8,
      maxScreensPerRow: 2,
      delayBetweenScreens: Duration.zero,
      testName: 'sample_flow',
    );

    final steps = <GoldenStep>[
      GoldenStep(
        stepName: 'Home',
        widgetBuilder: () => const ColoredBox(color: Colors.blue),
        setupAction: (tester) async {},
        verifyAction: (tester) async {},
      ),
      GoldenStep(
        stepName: 'Details',
        widgetBuilder: () => const ColoredBox(color: Colors.red),
      ),
    ];

    BcGoldenCapture.multiple('renders flow and matches golden', steps, config);
  });
}
