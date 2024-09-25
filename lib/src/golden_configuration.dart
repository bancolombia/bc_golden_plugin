import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

import 'helpers/asset_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// ## BcGoldenConfiguration
/// This class contains all the configuration that uses the tests to run.
/// For example the themes that the app uses could be configured in here.
/// * [themeProviders] A list of the providers used by the application.
class BcGoldenConfiguration {
  static final BcGoldenConfiguration _bcGoldenConfiguration =
      BcGoldenConfiguration._();

  factory BcGoldenConfiguration() {
    return _bcGoldenConfiguration;
  }

  BcGoldenConfiguration._();

  List<SingleChildWidget>? _themeProviders;
  ThemeData? _themeData;
  double _kGoldenDifferenceThreshold = 10;
  bool _willFailOnError = true;

  set themeProvider(List<SingleChildWidget>? providers) =>
      _themeProviders = providers;

  List<SingleChildWidget>? get themeProvider => _themeProviders;

  set themeData(ThemeData? themeData) => _themeData = themeData;

  ThemeData? get themeData => _themeData;

  set goldenDifferenceThreshold(double kGoldenDifferenceThreshold) =>
      _kGoldenDifferenceThreshold = kGoldenDifferenceThreshold;

  double get goldenDifferenceThreshold => _kGoldenDifferenceThreshold;

  set willFailOnError(bool willFailOnError) =>
      _willFailOnError = willFailOnError;

  bool get willFailOnError => _willFailOnError;
}

Future<void> loadConfiguration() async {
  await loadAppFonts();
  await loadMaterialIconFont();
}
