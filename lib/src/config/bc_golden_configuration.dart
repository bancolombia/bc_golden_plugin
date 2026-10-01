import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/single_child_widget.dart';

import '../helpers/asset_loader.dart';

/// ## BcGoldenConfiguration
/// This class contains all the configuration that uses the tests to run.
/// For example the themes that the app uses could be configured in here.
/// {@category Configuration}
class BcGoldenConfiguration {
  factory BcGoldenConfiguration() {
    return _bcGoldenConfiguration;
  }

  BcGoldenConfiguration._();

  /// [themeProvider] is a list of widgets that provide theme-related functionality.
  List<SingleChildWidget>? themeProvider;

  /// [themeData] is the data object that defines the theme for the application.
  ThemeData? themeData;

  /// Threshold used to decide whether a golden difference is acceptable.
  ///
  /// IMPORTANT: this value is a **percentage** of differing pixels in the range
  /// `0..100` (the comparator divides it by 100 internally). For example, `0.5`
  /// means a 0.5% tolerance and `10` means 10%.
  ///
  /// A high value makes the golden tests permissive to the point of missing
  /// real regressions (e.g. a text typo changes far less than 1% of pixels), so
  /// prefer small values. Setting a value greater than [_suspiciousThreshold]
  /// emits a warning, and values outside `0..100` are rejected.
  double get goldenDifferenceThreshold => _goldenDifferenceThreshold;

  set goldenDifferenceThreshold(double value) {
    assert(
      value >= 0 && value <= 100,
      'goldenDifferenceThreshold must be a percentage between 0 and 100. '
      'Received: $value',
    );

    if (value > _suspiciousThreshold) {
      debugPrint(
        '[bc_golden_plugin] WARNING: goldenDifferenceThreshold was set to '
        '$value%. This is a percentage (0..100), not a raw number. A value '
        'this high may hide real visual regressions. Typical values are below '
        '$_suspiciousThreshold%.',
      );
    }

    _goldenDifferenceThreshold = value;
  }

  /// The threshold expressed as a ratio in the range `0..1`, ready to be used by
  /// comparators. Equivalent to [goldenDifferenceThreshold] / 100.
  double get goldenDifferenceRatio => _goldenDifferenceThreshold / 100;

  /// Sets the tolerance using an explicit ratio in the range `0..1`.
  ///
  /// Prefer this setter when you want to avoid the percentage/ratio ambiguity,
  /// e.g. `setThresholdRatio(0.005)` for a 0.5% tolerance.
  void setThresholdRatio(double ratio) {
    assert(
      ratio >= 0 && ratio <= 1,
      'ratio must be between 0 and 1. Received: $ratio',
    );
    goldenDifferenceThreshold = ratio * 100;
  }

  double _goldenDifferenceThreshold = _defaultThreshold;

  /// [willFailOnError] indicates whether the process should fail when an error occurs,
  /// defaulting to true.
  bool willFailOnError = true;

  /// [shouldCreateFailuresFolder] indicates whether the failures folder should
  /// be created when the percentage difference is less than the configured value.
  /// defaulting to true.
  bool shouldCreateFailuresFolder = true;

  /// Default tolerance (percentage). Kept conservative so that golden tests
  /// catch real regressions out of the box.
  static const double _defaultThreshold = 10;

  /// Above this percentage a warning is emitted, since it usually indicates a
  /// misunderstanding of the unit rather than an intentional tolerance.
  static const double _suspiciousThreshold = 5;

  static final BcGoldenConfiguration _bcGoldenConfiguration =
      BcGoldenConfiguration._();
}

/// Loads the runtime configuration required by the golden tests.
///
/// * [currentPackage] When the test runs from inside a Flutter package
///   that ships its own font assets with local paths (e.g. icon fonts
///   declared in the package's own `pubspec.yaml` and consumed via
///   `IconData(..., fontPackage: '<currentPackage>')`), pass the package
///   name so that the fonts are also registered under the
///   `packages/<currentPackage>/<family>` alias. See [loadAppFonts] for
///   details.
Future<void> loadConfiguration({String? currentPackage}) async {
  await loadAppFonts(currentPackage: currentPackage);
  await loadMaterialIconFont();
}
