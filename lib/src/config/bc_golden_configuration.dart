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
  double goldenDifferenceThreshold = 10;

  /// [goldenDifferenceThreshold] is the threshold value for determining the difference
  /// between golden images and actual images, defaulting to 10.

  /// [willFailOnError] indicates whether the process should fail when an error occurs,
  /// defaulting to true.
  bool willFailOnError = true;

  static final BcGoldenConfiguration _bcGoldenConfiguration =
      BcGoldenConfiguration._();
}

Future<void> loadConfiguration() async {
  await loadAppFonts();
  await loadMaterialIconFont();
}
