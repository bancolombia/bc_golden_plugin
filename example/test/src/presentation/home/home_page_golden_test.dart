import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:example/src/presentation/home/home_page.dart';
import 'package:example/src/presentation/home/widgets/button_widget.dart';
import 'package:flutter/widgets.dart';

void main() {
  bcGoldenTest(
    'Test con custom window config data',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'golden',
        widget: const ButtonWidget(),
        tester: tester,
        device: bcCustomWindowConfigData(
          name: 'Prueba',
          pixelDensity: 3.0,
          size: const Size(375, 828),
        ),
      );
    },
  );

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

  BcGoldenCapture.multiple(
    'Multiple tests',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(title: 'Flutter Demo Home Page'),
      ),
      GoldenStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 1',
        ),
      ),
      GoldenStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 2',
        ),
      ),
      GoldenStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 3',
        ),
      ),
    ],
    GoldenCaptureConfig(
      testName: 'multiple_screens',
      device: GoldenDeviceData.galaxyS25,
      spacing: 100,
    ),
  );
}
