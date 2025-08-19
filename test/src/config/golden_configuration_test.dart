import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('golden configuration test', (tester) async {
    // Arrange
    final configuration = BcGoldenConfiguration();

    // Act
    configuration.themeProvider = [/* Add your providers here */];
    configuration.themeData = ThemeData(/* Add your theme data here */);
    configuration.goldenDifferenceThreshold = 20;
    configuration.willFailOnError = false;

    // Assert
    expect(configuration.themeProvider, isNotNull);
    expect(configuration.themeData, isNotNull);
    expect(configuration.goldenDifferenceThreshold, equals(20));
    expect(configuration.willFailOnError, isFalse);
  });
}
