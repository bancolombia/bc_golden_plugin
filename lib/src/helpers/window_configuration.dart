import 'package:flutter_test/flutter_test.dart';

import 'window_size.dart';

/// Dart extension to add configuration functions to a [WidgetTester] object,
/// e.g. [configureWindow], [configureOpenedKeyboardWindow],
/// [configureClosedKeyboardWindow].
extension WidgetTesterWithConfigurableWindow on WidgetTester {
  /// Configure the tester window to represent the given device variant.
  void configureWindow(WindowConfigData windowConfig) {
    this.view.physicalSize = windowConfig.physicalSize;
    this.view.devicePixelRatio = windowConfig.pixelDensity;
    this.view.padding = windowConfig.padding;
    this.view.viewPadding = windowConfig.padding;

    addTearDown(this.view.resetPadding);
    addTearDown(this.view.resetViewPadding);
    addTearDown(this.view.resetPhysicalSize);
    addTearDown(
      this.view.resetDevicePixelRatio,
    );
    addTearDown(this.view.resetViewInsets);
  }

  /// Configure the tester window to represent an opened keyboard on the given device variant.
  void configureOpenedKeyboardWindow(WindowConfigData windowConfig) {
    this.view.viewInsets = windowConfig.viewInsets;
    this.view.padding = windowConfig.padding.copyWith(bottom: 0);
  }

  /// Configure the tester window to represent a closed keyboard on the given device variant.
  void configureClosedKeyboardWindow(WindowConfigData windowConfig) {
    this.view.resetViewInsets();
    this.view.padding = windowConfig.padding;
  }
}
