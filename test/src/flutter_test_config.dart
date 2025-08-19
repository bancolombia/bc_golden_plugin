import 'dart:async';

import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

  bcGoldenConfiguration.goldenDifferenceThreshold = 10;
  bcGoldenConfiguration.willFailOnError = false;

  await loadConfiguration();

  await testMain();
}
