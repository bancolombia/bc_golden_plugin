import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/single_child_widget.dart';

import 'helpers/asset_loader.dart';

/// ## BcGoldenConfiguration
/// This class contains all the configuration that uses the tests to run.
/// For example the themes that the app uses could be configured in here.
/// * [themeProviders] A list of the providers used by the application.
class BcGoldenConfiguration {
  factory BcGoldenConfiguration() {
    return _bcGoldenConfiguration;
  }

  BcGoldenConfiguration._();

  List<SingleChildWidget>? themeProvider;
  ThemeData? themeData;
  double goldenDifferenceThreshold = 10;
  bool willFailOnError = true;

  static final BcGoldenConfiguration _bcGoldenConfiguration =
      BcGoldenConfiguration._();
}

Future<void> loadConfiguration() async {
  await loadAppFonts();
  await loadMaterialIconFont();
}
