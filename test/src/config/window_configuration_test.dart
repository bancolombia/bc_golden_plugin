import 'package:bc_golden_plugin/src/config/window_configuration.dart';
import 'package:bc_golden_plugin/src/testkit/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WindowConfiguration', () {
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
        expect(tester.view.padding, equals(windowConfig.padding));
        expect(tester.view.viewPadding, equals(windowConfig.padding));
      },
    );

    testWidgets(
      'configureOpenedKeyboardWindow sets view insets correctly',
      (tester) async {
        final windowConfig = WindowConfigData(
          'test device',
          size: const Size(400, 800),
          pixelDensity: 1.0,
          safeAreaPadding: const EdgeInsets.only(top: 20, bottom: 10),
          keyboardSize: const Size(400, 300),
          borderRadius: BorderRadius.zero,
          targetPlatform: TargetPlatform.android,
        );

        tester.configureWindow(windowConfig);

        tester.configureOpenedKeyboardWindow(windowConfig);

        expect(tester.view.viewInsets.bottom,
            equals(windowConfig.viewInsets.bottom));
        expect(tester.view.viewInsets.top, equals(windowConfig.viewInsets.top));
        expect(
            tester.view.viewInsets.left, equals(windowConfig.viewInsets.left));
        expect(tester.view.viewInsets.right,
            equals(windowConfig.viewInsets.right));

        expect(tester.view.padding.bottom, equals(0));
        expect(tester.view.padding.top, equals(windowConfig.padding.top));
        expect(tester.view.padding.left, equals(windowConfig.padding.left));
        expect(tester.view.padding.right, equals(windowConfig.padding.right));
      },
    );

    testWidgets(
      'configureClosedKeyboardWindow resets view insets',
      (tester) async {
        final windowConfig = WindowConfigData(
          'test device 2',
          size: const Size(320, 568),
          pixelDensity: 2.0,
          safeAreaPadding: const EdgeInsets.symmetric(vertical: 15),
          keyboardSize: const Size(320, 200),
          borderRadius: BorderRadius.zero,
          targetPlatform: TargetPlatform.iOS,
        );

        tester.configureWindow(windowConfig);

        tester.configureOpenedKeyboardWindow(windowConfig);

        tester.configureClosedKeyboardWindow(windowConfig);

        expect(tester.view.viewInsets.bottom, equals(0));
        expect(tester.view.viewInsets.top, equals(0));
        expect(tester.view.viewInsets.left, equals(0));
        expect(tester.view.viewInsets.right, equals(0));

        expect(tester.view.padding.bottom, equals(windowConfig.padding.bottom));
        expect(tester.view.padding.top, equals(windowConfig.padding.top));
        expect(tester.view.padding.left, equals(windowConfig.padding.left));
        expect(tester.view.padding.right, equals(windowConfig.padding.right));
      },
    );

    testWidgets(
      'multiple window configurations work correctly',
      (tester) async {
        final config1 = WindowConfigData(
          'config 1',
          size: const Size(800, 1200),
          pixelDensity: 3.0,
          safeAreaPadding: const EdgeInsets.all(20),
          keyboardSize: const Size(800, 400),
          borderRadius: BorderRadius.zero,
          targetPlatform: TargetPlatform.iOS,
        );

        final config2 = WindowConfigData(
          'config 2',
          size: const Size(600, 900),
          pixelDensity: 2.0,
          safeAreaPadding: const EdgeInsets.all(10),
          keyboardSize: const Size(600, 300),
          borderRadius: BorderRadius.zero,
          targetPlatform: TargetPlatform.android,
        );

        tester.configureWindow(config1);
        expect(tester.view.physicalSize, equals(config1.physicalSize));

        tester.configureWindow(config2);
        expect(tester.view.physicalSize, equals(config2.physicalSize));
        expect(tester.view.devicePixelRatio, equals(config2.pixelDensity));
      },
    );

    testWidgets(
      'keyboard state changes work with different configs',
      (tester) async {
        final configs = [
          WindowConfigData(
            'small config',
            size: const Size(320, 568),
            pixelDensity: 2.0,
            safeAreaPadding: const EdgeInsets.symmetric(vertical: 15),
            keyboardSize: const Size(320, 200),
            borderRadius: BorderRadius.zero,
            targetPlatform: TargetPlatform.iOS,
          ),
          WindowConfigData(
            'medium config',
            size: const Size(400, 800),
            pixelDensity: 2.0,
            safeAreaPadding: const EdgeInsets.all(10),
            keyboardSize: const Size(400, 300),
            borderRadius: BorderRadius.zero,
            targetPlatform: TargetPlatform.android,
          ),
          WindowConfigData(
            'large config',
            size: const Size(800, 1200),
            pixelDensity: 3.0,
            safeAreaPadding: const EdgeInsets.all(20),
            keyboardSize: const Size(800, 400),
            borderRadius: BorderRadius.zero,
            targetPlatform: TargetPlatform.iOS,
          ),
        ];

        for (final config in configs) {
          tester.configureWindow(config);

          tester.configureOpenedKeyboardWindow(config);
          expect(
              tester.view.viewInsets.bottom, equals(config.viewInsets.bottom));
          expect(tester.view.padding.bottom, equals(0));

          tester.configureClosedKeyboardWindow(config);
          expect(tester.view.viewInsets.bottom, equals(0));
          expect(tester.view.viewInsets.top, equals(0));
          expect(tester.view.padding.bottom, equals(config.padding.bottom));
          expect(tester.view.padding.top, equals(config.padding.top));
        }
      },
    );
  });
}
