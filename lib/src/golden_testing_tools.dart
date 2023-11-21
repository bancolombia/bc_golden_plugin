import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import 'helpers/asset_loader.dart';
import 'helpers/local_file_comparator_with_threshold.dart';
import 'helpers/test_base.dart';
import 'helpers/window_configuration.dart';
import 'helpers/window_size.dart';

const String _folderPath = "goldens";

/// ## bcGoldenTest
/// Function to call the golden test, it replaces the testWigets. This functions
/// are tagged with 'golden'.
///
/// * [description] A brief description of the test,
/// * [test] The test itself,
/// * [shouldUseRealShadows] Whether to render shadows or not,
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

///## bcWidgetMatchesImage
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

  final testUrl = (goldenFileComparator as LocalFileComparator).basedir.path;

  final String _imageFinalPath = "$testUrl$_folderPath/$imageName.png";

  if (device != null) tester.configureWindow(device);

  await tester.pumpWidget(
    BcGoldenBaseTest.appGoldenTest(
      widget: widget,
      width: width,
      height: height,
      textScaleFactor: textScaleFactor,
      customTheme: customTheme,
    ),
  );

  await loadAppFonts();

  await tester.awaitImages();

  await localFileComparator(testUrl);

  await expectLater(
    find.byType(widget.runtimeType),
    matchesGoldenFile(_imageFinalPath),
  );
}

///## CustomWindowConfigData
/// The purpose of this function it's to use a customized phone specifications.
/// * [name] Name of the configuration,
/// * [size] The viewport size of the device,
/// * [pixelDensity] Pixel ratio of the same viewport,
/// * [targetPlattform] If it's either Android or iOS,
/// * [safeAreaPadding] Padding used by the device in the safe areas,
WindowConfigData bcCustomWindowConfigData({
  required name,
  required size,
  required pixelDensity,
  targetPlatform = TargetPlatform.iOS,
  borderRadius,
  safeAreaPadding = EdgeInsets.zero,
}) {
  return WindowConfigData(
    name,
    size: size,
    pixelDensity: pixelDensity,
    targetPlatform: targetPlatform,
    borderRadius: borderRadius ?? BorderRadius.circular(48),
    safeAreaPadding: safeAreaPadding,
  );
}

///## convertToGolden
///This function is intended to remove the package parameter from the icons to
///succesfully render in test.
///
///i.e: BdsFunctionalIcons.HOME.convertToGolden()
extension IconExtension on IconData {
  IconData convertToGolden() {
    return IconData(
      codePoint,
      fontFamily: fontFamily,
    );
  }
}
