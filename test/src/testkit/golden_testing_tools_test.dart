import 'dart:async';

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

/// Widget that starts timers on mount, like widgets with animations,
/// splashes or delayed futures do. Used to reproduce
/// https://github.com/bancolombia/bc_golden_plugin/issues/35.
class _TimerStartingBox extends StatefulWidget {
  const _TimerStartingBox({required this.color});

  final Color color;

  @override
  State<_TimerStartingBox> createState() => _TimerStartingBoxState();
}

class _TimerStartingBoxState extends State<_TimerStartingBox> {
  @override
  Widget build(BuildContext context) => ColoredBox(color: widget.color);

  @override
  void initState() {
    super.initState();
    // A delayed future cannot be cancelled on dispose, so its internal
    // timer stays pending unless the test advances the clock past it.
    unawaited(Future<void>.delayed(const Duration(seconds: 5)));
  }
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

    // Regression test for issue #35: widgets that start timers must not
    // leave them pending between steps or at the end of the test.
    final timerSteps = <GoldenStep>[
      GoldenStep(
        stepName: 'Home',
        widgetBuilder: () => const _TimerStartingBox(color: Colors.blue),
      ),
      GoldenStep(
        stepName: 'Details',
        widgetBuilder: () => const _TimerStartingBox(color: Colors.red),
      ),
    ];

    BcGoldenCapture.multiple(
      'does not leak pending timers between steps',
      timerSteps,
      const GoldenCaptureConfig(
        layoutType: CaptureLayoutType.vertical,
        spacing: 8,
        maxScreensPerRow: 2,
        delayBetweenScreens: Duration.zero,
        testName: 'timer_flow',
      ),
    );
  });
}
