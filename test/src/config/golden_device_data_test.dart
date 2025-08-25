import 'package:bc_golden_plugin/src/config/golden_device_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenDeviceData Static Devices', () {
    testWidgets('Test iPhone 8 window config data', (tester) async {
      expect(GoldenDeviceData.iPhone8.name, 'iPhone 8');
      expect(GoldenDeviceData.iPhone8.size, const Size(375, 667));
      expect(GoldenDeviceData.iPhone8.pixelDensity, 2.0);
      expect(GoldenDeviceData.iPhone8.keyboardSize, const Size(375, 218));
      expect(GoldenDeviceData.iPhone8.borderRadius, BorderRadius.zero);
      expect(GoldenDeviceData.iPhone8.targetPlatform, TargetPlatform.iOS);
    });

    testWidgets('Test iPhone 13 window config data', (tester) async {
      expect(GoldenDeviceData.iPhone13.name, 'iPhone 13');
      expect(GoldenDeviceData.iPhone13.size, const Size(390, 844));
      expect(GoldenDeviceData.iPhone13.pixelDensity, 3.0);
      expect(GoldenDeviceData.iPhone13.keyboardSize, const Size(390, 302));
      expect(GoldenDeviceData.iPhone13.borderRadius, BorderRadius.circular(48));
      expect(GoldenDeviceData.iPhone13.targetPlatform, TargetPlatform.iOS);
    });

    testWidgets('Test iPhone 16 Pro Max window config data', (tester) async {
      expect(GoldenDeviceData.iPhone16ProMax.name, 'iPhone 16 Pro Max');
      expect(GoldenDeviceData.iPhone16ProMax.size, const Size(1320, 2868));
      expect(GoldenDeviceData.iPhone16ProMax.pixelDensity, 460.0);
      expect(
          GoldenDeviceData.iPhone16ProMax.keyboardSize, const Size(1320, 302));
      expect(GoldenDeviceData.iPhone16ProMax.borderRadius,
          BorderRadius.circular(48));
      expect(
          GoldenDeviceData.iPhone16ProMax.targetPlatform, TargetPlatform.iOS);
    });

    testWidgets('Test Galaxy S25 window config data', (tester) async {
      expect(GoldenDeviceData.galaxyS25.name, 'Galaxy S25');
      expect(GoldenDeviceData.galaxyS25.size, const Size(1080, 2340));
      expect(GoldenDeviceData.galaxyS25.pixelDensity, 416.0);
      expect(GoldenDeviceData.galaxyS25.keyboardSize, const Size(1080, 300));
      expect(
          GoldenDeviceData.galaxyS25.borderRadius, BorderRadius.circular(24));
      expect(GoldenDeviceData.galaxyS25.targetPlatform, TargetPlatform.android);
    });

    testWidgets('Test iPad Pro window config data', (tester) async {
      expect(GoldenDeviceData.iPadPro.name, 'iPad pro');
      expect(GoldenDeviceData.iPadPro.size, const Size(1366, 1024));
      expect(GoldenDeviceData.iPadPro.pixelDensity, 2.0);
      expect(GoldenDeviceData.iPadPro.keyboardSize, const Size(1366, 420));
      expect(GoldenDeviceData.iPadPro.borderRadius, BorderRadius.circular(24));
      expect(GoldenDeviceData.iPadPro.targetPlatform, TargetPlatform.iOS);
    });

    testWidgets('Test Nothing Phone (3) window config data', (tester) async {
      expect(GoldenDeviceData.nothingPhone3.name, 'Nothing Phone (3)');
      expect(GoldenDeviceData.nothingPhone3.size, const Size(1260, 2800));
      expect(GoldenDeviceData.nothingPhone3.pixelDensity, 460.0);
      expect(
          GoldenDeviceData.nothingPhone3.keyboardSize, const Size(1260, 300));
      expect(
        GoldenDeviceData.nothingPhone3.borderRadius,
        BorderRadius.circular(32),
      );
      expect(
        GoldenDeviceData.nothingPhone3.targetPlatform,
        TargetPlatform.android,
      );
    });

    testWidgets('Test Android FHD+ window config data', (tester) async {
      expect(GoldenDeviceData.androidFHDplus.name, 'Android FHD+ (1080×2400)');
      expect(GoldenDeviceData.androidFHDplus.size, const Size(1080, 2400));
      expect(GoldenDeviceData.androidFHDplus.pixelDensity, 400.0);
      expect(
          GoldenDeviceData.androidFHDplus.keyboardSize, const Size(1080, 300));
      expect(GoldenDeviceData.androidFHDplus.borderRadius, BorderRadius.zero);
      expect(
        GoldenDeviceData.androidFHDplus.targetPlatform,
        TargetPlatform.android,
      );
    });

    testWidgets('Test Standard iPhone window config data', (tester) async {
      expect(
          GoldenDeviceData.iPhoneStandard.name, 'Standard iPhone (1170×2532)');
      expect(GoldenDeviceData.iPhoneStandard.size, const Size(1170, 2532));
      expect(GoldenDeviceData.iPhoneStandard.pixelDensity, 460.0);
      expect(
          GoldenDeviceData.iPhoneStandard.keyboardSize, const Size(1170, 300));
      expect(GoldenDeviceData.iPhoneStandard.borderRadius, BorderRadius.zero);
      expect(
          GoldenDeviceData.iPhoneStandard.targetPlatform, TargetPlatform.iOS);
    });

    testWidgets('Test Android QHD+ window config data', (tester) async {
      expect(GoldenDeviceData.androidQHDplus.name, 'Android QHD+ (1440×3200)');
      expect(GoldenDeviceData.androidQHDplus.size, const Size(1440, 3200));
      expect(GoldenDeviceData.androidQHDplus.pixelDensity, 513.0);
      expect(
          GoldenDeviceData.androidQHDplus.keyboardSize, const Size(1440, 300));
      expect(
        GoldenDeviceData.androidQHDplus.borderRadius,
        BorderRadius.circular(24),
      );
      expect(
        GoldenDeviceData.androidQHDplus.targetPlatform,
        TargetPlatform.android,
      );
    });
  });

  group('Device Physical Size Calculations', () {
    test('iPhone 8 should calculate correct physical size', () {
      final physicalSize = GoldenDeviceData.iPhone8.physicalSize;

      expect(physicalSize.width, equals(375 * 2.0));
      expect(physicalSize.height, equals(667 * 2.0));
    });

    test('iPhone 16 Pro Max should calculate correct physical size', () {
      final physicalSize = GoldenDeviceData.iPhone16ProMax.physicalSize;

      expect(physicalSize.width, equals(1320 * 460.0));
      expect(physicalSize.height, equals(2868 * 460.0));
    });

    test('Galaxy S25 should calculate correct physical size', () {
      final physicalSize = GoldenDeviceData.galaxyS25.physicalSize;

      expect(physicalSize.width, equals(1080 * 416.0));
      expect(physicalSize.height, equals(2340 * 416.0));
    });

    test('iPad Pro should calculate correct physical size', () {
      final physicalSize = GoldenDeviceData.iPadPro.physicalSize;

      expect(physicalSize.width, equals(1366 * 2.0));
      expect(physicalSize.height, equals(1024 * 2.0));
    });
  });

  group('Device View Insets Calculations', () {
    test('iPhone 8 should calculate correct view insets', () {
      final viewInsets = GoldenDeviceData.iPhone8.viewInsets;

      expect(viewInsets.bottom, equals(218 * 2.0));
      expect(viewInsets.top, equals(0));
      expect(viewInsets.left, equals(0));
      expect(viewInsets.right, equals(0));
    });

    test('iPhone 13 should calculate correct view insets', () {
      final viewInsets = GoldenDeviceData.iPhone13.viewInsets;

      expect(viewInsets.bottom, equals(302 * 3.0));
      expect(viewInsets.top, equals(0));
      expect(viewInsets.left, equals(0));
      expect(viewInsets.right, equals(0));
    });

    test('Galaxy S25 should calculate correct view insets', () {
      final viewInsets = GoldenDeviceData.galaxyS25.viewInsets;

      expect(viewInsets.bottom, equals(300 * 416.0));
      expect(viewInsets.top, equals(0));
      expect(viewInsets.left, equals(0));
      expect(viewInsets.right, equals(0));
    });

    test('iPad Pro should calculate correct view insets', () {
      final viewInsets = GoldenDeviceData.iPadPro.viewInsets;

      expect(viewInsets.bottom, equals(420 * 2.0));
      expect(viewInsets.top, equals(0));
      expect(viewInsets.left, equals(0));
      expect(viewInsets.right, equals(0));
    });
  });

  group('Device Padding Calculations', () {
    test('iPhone 8 should have correct padding', () {
      final padding = GoldenDeviceData.iPhone8.padding;

      expect(padding.top, equals(0 * 2.0));
      expect(padding.bottom, equals(0 * 2.0));
      expect(padding.left, equals(0 * 2.0));
      expect(padding.right, equals(0 * 2.0));
    });

    test('iPhone 13 should have correct padding', () {
      final padding = GoldenDeviceData.iPhone13.padding;

      expect(padding.top, equals(0 * 3.0));
      expect(padding.bottom, equals(34 * 3.0));
      expect(padding.left, equals(0 * 3.0));
      expect(padding.right, equals(0 * 3.0));
    });

    test('iPhone 16 Pro Max should have correct padding', () {
      final padding = GoldenDeviceData.iPhone16ProMax.padding;

      expect(padding.top, equals(0 * 460.0));
      expect(padding.bottom, equals(34 * 460.0));
      expect(padding.left, equals(0 * 460.0));
      expect(padding.right, equals(0 * 460.0));
    });

    test('iPad Pro should have correct padding', () {
      final padding = GoldenDeviceData.iPadPro.padding;

      expect(padding.top, equals(24 * 2.0));
      expect(padding.bottom, equals(20 * 2.0));
      expect(padding.left, equals(0 * 2.0));
      expect(padding.right, equals(0 * 2.0));
    });
  });

  group('Device Platform Verification', () {
    test('all iPhone devices should have iOS platform', () {
      expect(GoldenDeviceData.iPhone8.targetPlatform, TargetPlatform.iOS);
      expect(GoldenDeviceData.iPhone13.targetPlatform, TargetPlatform.iOS);
      expect(
          GoldenDeviceData.iPhone16ProMax.targetPlatform, TargetPlatform.iOS);
      expect(
          GoldenDeviceData.iPhoneStandard.targetPlatform, TargetPlatform.iOS);
      expect(GoldenDeviceData.iPadPro.targetPlatform, TargetPlatform.iOS);
    });

    test('all Android devices should have Android platform', () {
      expect(GoldenDeviceData.galaxyS25.targetPlatform, TargetPlatform.android);
      expect(GoldenDeviceData.nothingPhone3.targetPlatform,
          TargetPlatform.android);
      expect(GoldenDeviceData.androidFHDplus.targetPlatform,
          TargetPlatform.android);
      expect(GoldenDeviceData.androidQHDplus.targetPlatform,
          TargetPlatform.android);
    });
  });

  group('Device Border Radius Verification', () {
    test('devices with no border radius', () {
      expect(GoldenDeviceData.iPhone8.borderRadius, BorderRadius.zero);
      expect(GoldenDeviceData.androidFHDplus.borderRadius, BorderRadius.zero);
      expect(GoldenDeviceData.iPhoneStandard.borderRadius, BorderRadius.zero);
    });

    test('devices with border radius', () {
      expect(GoldenDeviceData.iPhone13.borderRadius, BorderRadius.circular(48));
      expect(GoldenDeviceData.iPhone16ProMax.borderRadius,
          BorderRadius.circular(48));
      expect(
          GoldenDeviceData.galaxyS25.borderRadius, BorderRadius.circular(24));
      expect(GoldenDeviceData.nothingPhone3.borderRadius,
          BorderRadius.circular(32));
      expect(GoldenDeviceData.iPadPro.borderRadius, BorderRadius.circular(24));
      expect(GoldenDeviceData.androidQHDplus.borderRadius,
          BorderRadius.circular(24));
    });
  });
}
