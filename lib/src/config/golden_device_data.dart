import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../testkit/window_size.dart';

/// A class that represents the configuration data for golden device testing.
///
/// This class is used to store and manage the device-specific data
/// required for golden tests in the application. It may include
/// properties such as device name, screen size, pixel density, and
/// other relevant information that helps in rendering the UI
/// accurately for different devices.
class GoldenDeviceData {
  GoldenDeviceData._();

  // NOTE: `size` is in logical pixels (dp/pt) and `pixelDensity` is the
  // device pixel ratio (DPR), i.e. the @2x/@3x scale factor — NOT the screen
  // PPI. Flutter computes `physicalSize = size * pixelDensity` and assigns
  // `pixelDensity` to `view.devicePixelRatio`.

  static final WindowConfigData iPhone16ProMax = WindowConfigData(
    'iPhone 16 Pro Max',
    // Native 1320×2868 px @3x ⇒ 440×956 pt.
    size: const Size(440, 956),
    pixelDensity: 3.0,
    safeAreaPadding: const EdgeInsets.only(bottom: 34),
    keyboardSize: const Size(440, 302),
    borderRadius: BorderRadius.circular(48),
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData nothingPhone3 = WindowConfigData(
    'Nothing Phone (3)',
    // Native 1260×2800 px @3x ⇒ 420×933 dp.
    size: const Size(420, 933),
    pixelDensity: 3.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(420, 300),
    borderRadius: BorderRadius.circular(32),
    targetPlatform: TargetPlatform.android,
  );

  static final WindowConfigData galaxyS25 = WindowConfigData(
    'Galaxy S25',
    // Native 1080×2340 px @3x ⇒ 360×780 dp.
    size: const Size(360, 780),
    pixelDensity: 3.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(360, 300),
    borderRadius: BorderRadius.circular(24),
    targetPlatform: TargetPlatform.android,
  );

  // Resoluciones comunes generales:
  static final WindowConfigData androidFHDplus = WindowConfigData(
    'Android FHD+ (1080×2400)',
    // Native 1080×2400 px @3x ⇒ 360×800 dp.
    size: const Size(360, 800),
    pixelDensity: 3.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(360, 300),
    borderRadius: BorderRadius.zero,
    targetPlatform: TargetPlatform.android,
  );

  static final WindowConfigData iPhoneStandard = WindowConfigData(
    'Standard iPhone (1170×2532)',
    // Native 1170×2532 px @3x ⇒ 390×844 pt.
    size: const Size(390, 844),
    pixelDensity: 3.0,
    safeAreaPadding: const EdgeInsets.only(bottom: 34),
    keyboardSize: const Size(390, 300),
    borderRadius: BorderRadius.zero,
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData androidQHDplus = WindowConfigData(
    'Android QHD+ (1440×3200)',
    // Native 1440×3200 px @4x ⇒ 360×800 dp (matches FHD+ layout at higher
    // pixel density, as most Android QHD+ devices report).
    size: const Size(360, 800),
    pixelDensity: 4.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(360, 300),
    borderRadius: BorderRadius.circular(24),
    targetPlatform: TargetPlatform.android,
  );

  static final WindowConfigData iPhone8 = WindowConfigData(
    'iPhone 8',
    size: const Size(375, 667),
    pixelDensity: 2.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(375, 218),
    borderRadius: BorderRadius.zero,
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData iPhone13 = WindowConfigData(
    'iPhone 13',
    size: const Size(390, 844),
    pixelDensity: 3.0,
    safeAreaPadding: const EdgeInsets.only(bottom: 34),
    keyboardSize: const Size(390, 302),
    borderRadius: BorderRadius.circular(48),
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData iPadPro = WindowConfigData(
    'iPad pro',
    size: const Size(1366, 1024),
    pixelDensity: 2.0,
    safeAreaPadding: const EdgeInsets.only(top: 24, bottom: 20),
    keyboardSize: const Size(1366, 420),
    borderRadius: BorderRadius.circular(24),
    targetPlatform: TargetPlatform.iOS,
  );
}

@Deprecated('Use GoldenDeviceData instead')

/// [WindowConfigData] for an iPhone 8.
final WindowConfigData iPhone8 = WindowConfigData(
  'iPhone 8',
  size: const Size(375, 667),
  pixelDensity: 2.0,
  safeAreaPadding: EdgeInsets.zero,
  keyboardSize: const Size(375, 218),
  borderRadius: BorderRadius.zero,
  targetPlatform: TargetPlatform.iOS,
);

@Deprecated('Use GoldenDeviceData instead')

/// [WindowConfigData] for an iPhone 13.
final WindowConfigData iPhone13 = WindowConfigData(
  'iPhone 13',
  size: const Size(390, 844),
  pixelDensity: 3.0,
  safeAreaPadding: const EdgeInsets.only(bottom: 34),
  keyboardSize: const Size(390, 302),
  borderRadius: BorderRadius.circular(48),
  targetPlatform: TargetPlatform.iOS,
);

@Deprecated('Use GoldenDeviceData instead')

/// [WindowConfigData] for an iPhone 14 Pro Max.
final WindowConfigData iPhone14ProMax = WindowConfigData(
  'iPhone 14 Pro Max',
  size: const Size(430, 932),
  pixelDensity: 3.0,
  safeAreaPadding: const EdgeInsets.only(bottom: 34),
  keyboardSize: const Size(390, 302),
  borderRadius: BorderRadius.circular(48),
  targetPlatform: TargetPlatform.iOS,
);

@Deprecated('Use GoldenDeviceData instead')

/// [WindowConfigData] for a Google Pixel 5.
final WindowConfigData pixel5 = WindowConfigData(
  'Pixel 5',
  size: const Size(360, 764),
  pixelDensity: 3.0,
  safeAreaPadding: EdgeInsets.zero,
  keyboardSize: const Size(360, 297),
  borderRadius: BorderRadius.circular(32),
  targetPlatform: TargetPlatform.android,
);

@Deprecated('Use GoldenDeviceData instead')

/// [WindowConfigData] for a 12.9" iPad Pro.
final WindowConfigData iPadPro = WindowConfigData(
  'iPad pro',
  size: const Size(1366, 1024),
  pixelDensity: 2.0,
  safeAreaPadding: const EdgeInsets.only(top: 24, bottom: 20),
  keyboardSize: const Size(1366, 420),
  borderRadius: BorderRadius.circular(24),
  targetPlatform: TargetPlatform.iOS,
);
