import 'package:bc_golden_plugin/src/helpers/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_golden_plugin/src/golden_testing_tools.dart';

void main() {
  test('bcCustomWindowConfigData should return a WindowConfigData object', () {
    final configData = bcCustomWindowConfigData(
      name: 'Custom Config',
      size: Size(360, 640),
      pixelDensity: 2.0,
    );
    expect(configData, isA<WindowConfigData>());
  });

  test('IconExtension.convertToGolden should return an IconData object', () {
    final iconData = IconData(0xe900, fontFamily: 'BdsFunctionalIcons');
    final convertedIcon = iconData.convertToGolden();
    expect(convertedIcon, isA<IconData>());
  });
}
