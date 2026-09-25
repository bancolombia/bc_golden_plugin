// Verifies that the public barrel (`package:bc_golden_plugin/bc_golden_plugin.dart`)
// exposes the symbols consumers need, so they never have to import internal
// `src/...` paths. If any of these were not exported, this file would fail to
// compile.
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('public barrel exports', () {
    test('exposes the threshold-aware comparator symbols', () {
      // Assert: the type and the installer function are reachable from the
      // public barrel (referencing them here is enough; compilation proves it).
      expect(LocalFileComparatorWithThreshold, isNotNull);
      expect(localFileComparator, isA<Function>());
    });

    test('exposes the device viewport types', () {
      // Act
      final WindowConfigData device = bcCustomWindowConfigData(
        name: 'sample',
        size: const Size(360, 640),
        pixelDensity: 2,
      );

      // Assert
      expect(device, isA<WindowConfigData>());
      expect(WindowConfig, isNotNull);
    });
  });
}
