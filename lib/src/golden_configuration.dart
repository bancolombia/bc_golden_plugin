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

  set setThemeProvider(List<SingleChildWidget> providers) =>
      _themeProviders = providers;

  List<SingleChildWidget>? get getThemeProvider => _themeProviders;

  set setThemeData(ThemeData themeData) => _themeData = themeData;

  ThemeData? get getThemeData => _themeData;

  set setGoldenDifferenceThreshold(double kGoldenDifferenceThreshold) =>
      _kGoldenDifferenceThreshold = kGoldenDifferenceThreshold;

  double get getGoldenDifferenceThreshold => _kGoldenDifferenceThreshold;

  set setWillFailOnError(bool willFailOnError) =>
      _willFailOnError = willFailOnError;

  bool get getWillFailOnError => _willFailOnError;
}

Future<void> loadConfiguration() async {
  await loadAppFonts();
  await loadMaterialIconFont();
}
