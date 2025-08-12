import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../testkit/window_size.dart';

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
