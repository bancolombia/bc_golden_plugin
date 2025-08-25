import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:example/src/presentation/another_page/another_page.dart';
import 'package:example/src/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bcGoldenTest(
    'Test con iPhone 14 pro max',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'golden_iphone_14_pro',
        widget: const HomePage(title: 'Flutter Demo Home Page'),
        tester: tester,
        device: GoldenDeviceData.iPhone16ProMax,
        textScaleFactor: 3.0,
      );
    },
    shouldUseRealShadows: true,
  );

  BcGoldenCapture.single(
    'Single test',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'golden_single',
        widget: const HomePage(title: 'Flutter Demo Home Page'),
        tester: tester,
        device: GoldenDeviceData.galaxyS25,
      );
    },
  );

  BcGoldenCapture.multiple(
    'Multiple test',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(title: 'Flutter Demo Home Page'),
      ),
      GoldenStep(
        stepName: 'home 2',
        widgetBuilder: () => HomePage(
          title: 'Page 1',
          backgroundColor: Colors.red[100],
        ),
      ),
      GoldenStep(
        stepName: 'home 3',
        widgetBuilder: () => HomePage(
          title: 'Page 2',
          backgroundColor: Colors.green[100],
        ),
      ),
      GoldenStep(
        stepName: 'Another page',
        widgetBuilder: () => const AnotherPage(),
      ),
    ],
    GoldenCaptureConfig(
      testName: 'multiple_screens',
      device: GoldenDeviceData.iPhone13,
      spacing: 100,
    ),
  );

  testWidgets('Manual golden test', (tester) async {
    await tester.runAsync(() async {
      GoldenScreenshot screenshotter = GoldenScreenshot();

      tester.configureWindow(
        GoldenDeviceData.iPhone13,
      );

      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: const HomePage(title: 'Flutter Demo Home Page'),
          key: GlobalKey(),
        ),
      );

      await tester.pumpAndSettle();

      await screenshotter.captureScreenshot();

      await tester.tap(
        find.byKey(
          const Key('button_widget_key'),
        ),
      );

      await tester.pumpAndSettle();

      await screenshotter.captureScreenshot();

      final combinedScreenshot = await screenshotter.combineScreenshots(
        GoldenCaptureConfig(
          testName: 'manual_golden',
          device: GoldenDeviceData.iPhone13,
          layoutType: CaptureLayoutType.horizontal,
        ),
        ['home', 'another'],
      );

      await expectLater(
        combinedScreenshot,
        matchesGoldenFile('goldens/manual_golden.png'),
      );
    });
  });
}
