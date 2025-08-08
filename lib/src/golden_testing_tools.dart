import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import 'helpers/helpers.dart';
import 'models/golden_flow_config.dart';

const String _folderPath = 'goldens';

/// ## bcGoldenTest
/// Function to call the golden test, it replaces the testWigets. This functions
/// are tagged with 'golden'.
///
/// * [description] A brief description of the test.
/// * [test] The test itself.
/// * [shouldUseRealShadows] Whether to render shadows or not.
@isTest
void bcGoldenTest(
  String description,
  Future<void> Function(WidgetTester) test, {
  bool shouldUseRealShadows = true,
}) {
  testWidgets(
    description,
    (widgetTester) async {
      body() async {
        final initialDebugDisableShadowsValue = debugDisableShadows;
        debugDisableShadows = !shouldUseRealShadows;
        try {
          await test(widgetTester);
        } finally {
          debugDisableShadows = initialDebugDisableShadowsValue;
          debugDefaultTargetPlatformOverride = null;
        }
      }

      await body();
    },
    tags: ['golden'],
  );
}

/// ## goldenFlowTest
/// A test function that executes a series of steps for golden testing.
///
/// This function takes a list of `FlowStep` objects and performs the following:
/// 1. Renders each step's widget using the provided `widgetBuilder`.
/// 2. Executes any setup actions defined in the `FlowStep`.
/// 3. Captures a screenshot after rendering each step.
/// 4. Combines all captured screenshots into a single image.
/// 5. Compares the combined image against a golden file to ensure visual consistency.
///
/// Parameters:
/// - [tester]: The widget tester used to interact with the widget tree.
/// - [description]: A description of the test case.
/// - [steps]: A list of `FlowStep` objects that define the steps to be executed.
/// - [config]: A configuration object that contains settings for the golden flow test.
///
/// Each `FlowStep` can define:
/// - `widgetBuilder`: A function that returns the widget to be rendered.
/// - `setupAction`: An optional function to perform setup actions before capturing the screenshot.
/// - `verifyAction`: An optional function to perform verification actions after rendering the widget.
///
/// The combined screenshot is saved in the 'goldens' directory with a filename based on the test name.
@isTest
void goldenFlowTest(
  String description,
  List<FlowStep> steps,
  GoldenFlowConfig config,
) {
  testWidgets(description, (tester) async {
    final screenshots = <Uint8List>[];

    if (config.device != null) {
      tester.configureWindow(config.device!);
    }

    await loadAppFonts();

    await tester.awaitImages();

    for (int index = 0; index < steps.length; index++) {
      final step = steps[index];

      logDebug(
        '[flows][test] Rendering step ${index + 1}/${steps.length}: ${step.stepName}',
      );

      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: step.widgetBuilder(),
          key: GlobalKey(),
        ),
      );

      logDebug(
        '[flows][test] ✓ Rendered step ${index + 1}/${steps.length}: ${step.stepName}',
      );

      if (step.setupAction != null) {
        await step.setupAction!(tester);
      }

      logDebug(
        '[flows][test] ✓ Setup action completed for step ${index + 1}/${steps.length}: ${step.stepName}',
      );

      await tester.pumpAndSettle();

      if (index > 0) {
        await tester.pump(config.delayBetweenScreens);
      }

      if (step.verifyAction != null) {
        await step.verifyAction!(tester);
      }

      logDebug(
        '[flows][test] ✓ Verify action completed for step ${index + 1}/${steps.length}: ${step.stepName}',
      );

      await tester.runAsync(() async {
        final screenshot = await captureScreenshot();
        logDebug(
          '[flows][test] ✓ Captured screenshot for step ${index + 1}/${steps.length}: ${step.stepName}',
        );

        screenshots.add(screenshot);
      });
    }

    logDebug('[flows][test] Combining screenshots...');

    await tester.runAsync(() async {
      final combinedImage = await combineScreenshots(
        screenshots,
        config,
        steps.map((s) => s.stepName).toList(),
      );

      logDebug('[flows][test] ✓ Combined screenshots successfully.');

      await expectLater(
        combinedImage,
        matchesGoldenFile('goldens/${config.testName}_flow.png'),
      );
    });
  });
}

/// ## bcWidgetMatchesImage
/// This function is intended to receive an image (as the design input) and
/// render the widget to test according to the given image dimensions.
/// * [imageName] Name of the image without the extension.
/// * [widget] The widget to render and compare.
/// * [tester] The widget tester used in the parent function.
/// * [width] (optional), if not set it will render the widget with a default
/// width.
/// * [height] (optional), if not set it will render the widget with a default
/// height.
/// * [device] (optional), no device data by default, this will render the
/// test with phone screen specifications.
/// * [customTheme] (optional) if set, it will override the default theme
/// given in the BcGoldenConfiguration for one test only.
Future<void> bcWidgetMatchesImage({
  required String imageName,
  required Widget widget,
  required WidgetTester tester,
  double? width,
  double? height,
  double? textScaleFactor,
  WindowConfigData? device,
  ThemeData? customTheme,
}) async {
  assert(!imageName.endsWith('.png'), 'The image cannot have type extension');

  final testPath = (goldenFileComparator as LocalFileComparator).basedir.path;

  final String imageFinalPath = '$testPath$_folderPath/$imageName.png';

  if (device != null) tester.configureWindow(device);

  await tester.pumpWidget(
    TestBase.appGoldenTest(
      widget: widget,
      width: width,
      height: height,
      textScaleFactor: textScaleFactor,
      customTheme: customTheme,
    ),
  );

  await tester.awaitImages();

  await loadAppFonts();

  await localFileComparator(testPath);

  await expectLater(
    find.byWidget(widget),
    matchesGoldenFile(imageFinalPath),
  );
}

/// ## CustomWindowConfigData
/// The purpose of this function it's to use a customized phone specifications.
/// * [name] Name of the configuration.
/// * [size] The viewport size of the device.
/// * [pixelDensity] Pixel ratio of the same viewport.
/// * [targetPlattform] If it's either Android or iOS.
/// * [safeAreaPadding] Padding used by the device in the safe areas.
WindowConfigData bcCustomWindowConfigData({
  required name,
  required size,
  required pixelDensity,
  targetPlatform = TargetPlatform.iOS,
  borderRadius,
  safeAreaPadding = EdgeInsets.zero,
}) {
  const double radius = 48;

  return WindowConfigData(
    name,
    size: size,
    pixelDensity: pixelDensity,
    targetPlatform: targetPlatform,
    borderRadius: borderRadius ?? BorderRadius.circular(radius),
    safeAreaPadding: safeAreaPadding,
  );
}

/// ## convertToGolden
/// This function is intended to remove the package parameter from the icons to
/// succesfully render in test.
///
///i.e: BdsFunctionalIcons.HOME.convertToGolden().
extension IconExtension on IconData {
  IconData convertToGolden() {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
    );
  }
}
