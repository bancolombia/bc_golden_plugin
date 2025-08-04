import 'package:bc_golden_plugin/src/golden_device_data.dart';
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
}
