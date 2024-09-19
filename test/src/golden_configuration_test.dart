import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bc_golden_plugin/src/golden_configuration.dart';

void main() {
  testWidgets('golden configuration test', (tester) async {
    // Arrange
    final configuration = BcGoldenConfiguration();

    // Act
    configuration.setThemeProvider = [/* Add your providers here */];
    configuration.setThemeData = ThemeData(/* Add your theme data here */);
    configuration.setGoldenDifferenceThreshold = 20;
    configuration.setWillFailOnError = false;

    // Assert
    expect(configuration.getThemeProvider, isNotNull);
    expect(configuration.getThemeData, isNotNull);
    expect(configuration.getGoldenDifferenceThreshold, equals(20));
    expect(configuration.getWillFailOnError, isFalse);
  });
}
