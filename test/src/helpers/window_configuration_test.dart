import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_golden_plugin/src/helpers/window_configuration.dart';
import 'package:bc_golden_plugin/src/helpers/window_size.dart';

void main() {
  testWidgets('configureWindow sets the tester window configuration correctly',
      (tester) async {
    final windowConfig = WindowConfigData(
      'iphone 8',
      size: const Size(375, 667),
      pixelDensity: 2.0,
      safeAreaPadding: EdgeInsets.zero,
      keyboardSize: const Size(375, 218),
      borderRadius: BorderRadius.zero,
      targetPlatform: TargetPlatform.iOS,
    );

    tester.configureWindow(windowConfig);

    expect(tester.view.physicalSize, equals(windowConfig.physicalSize));
    expect(tester.view.devicePixelRatio, equals(windowConfig.pixelDensity));
  });

  // testWidgets(
  //     'configureOpenedKeyboardWindow sets the tester window configuration for opened keyboard correctly',
  //     (tester) async {
  //   final windowConfig = WindowConfigData(
  //     viewInsets: EdgeInsets.only(bottom: 100.0),
  //     padding: EdgeInsets.all(16.0),
  //   );

  //   tester.configureOpenedKeyboardWindow(windowConfig);

  //   expect(tester.binding.window.viewInsetsTestValue,
  //       equals(windowConfig.viewInsets));
  //   expect(tester.binding.window.paddingTestValue,
  //       equals(windowConfig.padding.copyWith(bottom: 0)));
  // });

  // testWidgets(
  //     'configureClosedKeyboardWindow sets the tester window configuration for closed keyboard correctly',
  //     (tester) async {
  //   final windowConfig = WindowConfigData(
  //     padding: EdgeInsets.all(16.0),
  //   );

  //   tester.configureClosedKeyboardWindow(windowConfig);

  //   expect(tester.binding.window.viewInsetsTestValue, isNull);
  //   expect(
  //       tester.binding.window.paddingTestValue, equals(windowConfig.padding));
  // });
}
