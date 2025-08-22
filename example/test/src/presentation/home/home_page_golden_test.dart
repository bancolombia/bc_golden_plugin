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

  goldenFlowTest(
    'Multiple tests',
    [
      FlowStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(title: 'Flutter Demo Home Page'),
      ),
      FlowStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 1',
        ),
      ),
      FlowStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 2',
        ),
      ),
      FlowStep(
        stepName: 'home2',
        widgetBuilder: () => const HomePage(
          title: 'Page 3',
        ),
      ),
    ],
    GoldenFlowConfig(
      testName: 'multiple_screens',
      device: GoldenDeviceData.galaxyS25,
      spacing: 100,
    ),
  );

  // Example demonstrating the new timeout parameters for complex animations
  bcGoldenTest(
    'Test with custom timeout for animations',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'animation_test',
        widget: const HomePage(title: 'Animated Page'),
        tester: tester,
        device: GoldenDeviceData.iPhone16ProMax,
        // Custom timeout to handle long-running animations
        pumpAndSettleTimeout: const Duration(seconds: 30),
        // Faster pump duration for quicker animation steps
        pumpDuration: const Duration(milliseconds: 50),
      );
    },
    shouldUseRealShadows: true,
  );

  goldenFlowTest(
    'Flow test with timeout control',
    [
      FlowStep(
        stepName: 'animated_home',
        widgetBuilder: () => const HomePage(title: 'Animated Demo'),
      ),
      FlowStep(
        stepName: 'animated_second',
        widgetBuilder: () => const HomePage(title: 'Second Animated Page'),
      ),
    ],
    GoldenFlowConfig(
      testName: 'animated_flow',
      device: GoldenDeviceData.galaxyS25,
      spacing: 50,
    ),
    // Custom timeout parameters for the entire flow
    pumpAndSettleTimeout: const Duration(seconds: 15),
    pumpDuration: const Duration(milliseconds: 100),
  );
}
