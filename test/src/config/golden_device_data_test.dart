import 'package:bc_golden_plugin/src/config/golden_device_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test iPhone 8 window config data', (tester) async {
    expect(iPhone8.name, 'iPhone 8');
    expect(iPhone8.size, const Size(375, 667));
    expect(iPhone8.pixelDensity, 2.0);
    expect(iPhone8.keyboardSize, const Size(375, 218));
    expect(iPhone8.borderRadius, BorderRadius.zero);
    expect(iPhone8.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test iPhone 13 window config data', (tester) async {
    expect(iPhone13.name, 'iPhone 13');
    expect(iPhone13.size, const Size(390, 844));
    expect(iPhone13.pixelDensity, 3.0);
    expect(iPhone13.keyboardSize, const Size(390, 302));
    expect(iPhone13.borderRadius, BorderRadius.circular(48));
    expect(iPhone13.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test iPhone 14 Pro Max window config data', (tester) async {
    expect(iPhone14ProMax.name, 'iPhone 14 Pro Max');
    expect(iPhone14ProMax.size, const Size(430, 932));
    expect(iPhone14ProMax.pixelDensity, 3.0);
    expect(iPhone14ProMax.keyboardSize, const Size(390, 302));
    expect(iPhone14ProMax.borderRadius, BorderRadius.circular(48));
    expect(iPhone14ProMax.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test Pixel 5 window config data', (tester) async {
    expect(pixel5.name, 'Pixel 5');
    expect(pixel5.size, const Size(360, 764));
    expect(pixel5.pixelDensity, 3.0);
    expect(pixel5.keyboardSize, const Size(360, 297));
    expect(pixel5.borderRadius, BorderRadius.circular(32));
    expect(pixel5.targetPlatform, TargetPlatform.android);
  });

  testWidgets('Test iPad Pro window config data', (tester) async {
    expect(iPadPro.name, 'iPad pro');
    expect(iPadPro.size, const Size(1366, 1024));
    expect(iPadPro.pixelDensity, 2.0);
    expect(iPadPro.keyboardSize, const Size(1366, 420));
    expect(iPadPro.borderRadius, BorderRadius.circular(24));
    expect(iPadPro.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test iPhone 16 Pro Max window config data', (tester) async {
    expect(GoldenDeviceData.iPhone16ProMax.name, 'iPhone 16 Pro Max');
    expect(GoldenDeviceData.iPhone16ProMax.size, const Size(1320, 2868));
    expect(GoldenDeviceData.iPhone16ProMax.pixelDensity, 460.0);
    expect(GoldenDeviceData.iPhone16ProMax.keyboardSize, const Size(1320, 302));
    expect(
      GoldenDeviceData.iPhone16ProMax.borderRadius,
      BorderRadius.circular(48),
    );
    expect(GoldenDeviceData.iPhone16ProMax.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test Nothing Phone (3) window config data', (tester) async {
    expect(GoldenDeviceData.nothingPhone3.name, 'Nothing Phone (3)');
    expect(GoldenDeviceData.nothingPhone3.size, const Size(1260, 2800));
    expect(GoldenDeviceData.nothingPhone3.pixelDensity, 460.0);
    expect(GoldenDeviceData.nothingPhone3.keyboardSize, const Size(1260, 300));
    expect(
      GoldenDeviceData.nothingPhone3.borderRadius,
      BorderRadius.circular(32),
    );
    expect(
      GoldenDeviceData.nothingPhone3.targetPlatform,
      TargetPlatform.android,
    );
  });

  testWidgets('Test Galaxy S25 window config data', (tester) async {
    expect(GoldenDeviceData.galaxyS25.name, 'Galaxy S25');
    expect(GoldenDeviceData.galaxyS25.size, const Size(1080, 2340));
    expect(GoldenDeviceData.galaxyS25.pixelDensity, 416.0);
    expect(GoldenDeviceData.galaxyS25.keyboardSize, const Size(1080, 300));
    expect(GoldenDeviceData.galaxyS25.borderRadius, BorderRadius.circular(24));
    expect(GoldenDeviceData.galaxyS25.targetPlatform, TargetPlatform.android);
  });

  testWidgets('Test Android FHD+ window config data', (tester) async {
    expect(GoldenDeviceData.androidFHDplus.name, 'Android FHD+ (1080×2400)');
    expect(GoldenDeviceData.androidFHDplus.size, const Size(1080, 2400));
    expect(GoldenDeviceData.androidFHDplus.pixelDensity, 400.0);
    expect(GoldenDeviceData.androidFHDplus.keyboardSize, const Size(1080, 300));
    expect(GoldenDeviceData.androidFHDplus.borderRadius, BorderRadius.zero);
    expect(
      GoldenDeviceData.androidFHDplus.targetPlatform,
      TargetPlatform.android,
    );
  });

  testWidgets('Test Standard iPhone window config data', (tester) async {
    expect(GoldenDeviceData.iPhoneStandard.name, 'Standard iPhone (1170×2532)');
    expect(GoldenDeviceData.iPhoneStandard.size, const Size(1170, 2532));
    expect(GoldenDeviceData.iPhoneStandard.pixelDensity, 460.0);
    expect(GoldenDeviceData.iPhoneStandard.keyboardSize, const Size(1170, 300));
    expect(GoldenDeviceData.iPhoneStandard.borderRadius, BorderRadius.zero);
    expect(GoldenDeviceData.iPhoneStandard.targetPlatform, TargetPlatform.iOS);
  });

  testWidgets('Test Android QHD+ window config data', (tester) async {
    expect(GoldenDeviceData.androidQHDplus.name, 'Android QHD+ (1440×3200)');
    expect(GoldenDeviceData.androidQHDplus.size, const Size(1440, 3200));
    expect(GoldenDeviceData.androidQHDplus.pixelDensity, 513.0);
    expect(GoldenDeviceData.androidQHDplus.keyboardSize, const Size(1440, 300));
    expect(
      GoldenDeviceData.androidQHDplus.borderRadius,
      BorderRadius.circular(24),
    );
    expect(
      GoldenDeviceData.androidQHDplus.targetPlatform,
      TargetPlatform.android,
    );
  });
}
