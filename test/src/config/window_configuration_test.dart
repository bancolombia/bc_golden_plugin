import 'package:bc_golden_plugin/src/config/window_configuration.dart';
import 'package:bc_golden_plugin/src/testkit/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'configureWindow sets the tester window configuration correctly',
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
    },
  );
}
