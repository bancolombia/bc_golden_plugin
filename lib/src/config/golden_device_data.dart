import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../testkit/window_size.dart';

class GoldenDeviceData {
  GoldenDeviceData._();

  static final WindowConfigData iPhone16ProMax = WindowConfigData(
    'iPhone 16 Pro Max',
    size: const Size(1320, 2868),
    pixelDensity: 460.0,
    safeAreaPadding: const EdgeInsets.only(bottom: 34),
    keyboardSize: const Size(1320, 302),
    borderRadius: BorderRadius.circular(48),
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData nothingPhone3 = WindowConfigData(
    'Nothing Phone (3)',
    size: const Size(1260, 2800),
    pixelDensity: 460.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(1260, 300),
    borderRadius: BorderRadius.circular(32),
    targetPlatform: TargetPlatform.android,
  );

  static final WindowConfigData galaxyS25 = WindowConfigData(
    'Galaxy S25',
    size: const Size(1080, 2340),
    pixelDensity: 416.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(1080, 300),
    borderRadius: BorderRadius.circular(24),
    targetPlatform: TargetPlatform.android,
  );

  // Resoluciones comunes generales:
  static final WindowConfigData androidFHDplus = WindowConfigData(
    'Android FHD+ (1080×2400)',
    size: const Size(1080, 2400),
    pixelDensity: 400.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(1080, 300),
    borderRadius: BorderRadius.zero,
    targetPlatform: TargetPlatform.android,
  );

  static final WindowConfigData iPhoneStandard = WindowConfigData(
    'Standard iPhone (1170×2532)',
    size: const Size(1170, 2532),
    pixelDensity: 460.0,
    safeAreaPadding: const EdgeInsets.only(bottom: 34),
    keyboardSize: const Size(1170, 300),
    borderRadius: BorderRadius.zero,
    targetPlatform: TargetPlatform.iOS,
  );

  static final WindowConfigData androidQHDplus = WindowConfigData(
    'Android QHD+ (1440×3200)',
    size: const Size(1440, 3200),
    pixelDensity: 513.0,
    safeAreaPadding: EdgeInsets.zero,
    keyboardSize: const Size(1440, 300),
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
