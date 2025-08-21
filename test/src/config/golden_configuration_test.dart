import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('BcGoldenConfiguration', () {
    test('should be a singleton', () {
      final configuration1 = BcGoldenConfiguration();
      final configuration2 = BcGoldenConfiguration();

      expect(configuration1, same(configuration2));
    });

    test('should have default values', () {
      final configuration = BcGoldenConfiguration();

      expect(configuration.themeProvider, isNull);
      expect(configuration.themeData, isNull);
      expect(configuration.goldenDifferenceThreshold, equals(10));
      expect(configuration.willFailOnError, isFalse);
    });

    test('should allow setting themeProvider', () {
      final configuration = BcGoldenConfiguration();
      final provider = ChangeNotifierProvider<ValueNotifier<String>>(
        create: (_) => ValueNotifier('test'),
        child: const SizedBox(),
      );

      configuration.themeProvider = [provider];

      expect(configuration.themeProvider, isNotNull);
      expect(configuration.themeProvider, hasLength(1));
      expect(configuration.themeProvider?.first, same(provider));
    });

    test('should allow setting themeData', () {
      final configuration = BcGoldenConfiguration();
      final themeData = ThemeData.light();

      configuration.themeData = themeData;

      expect(configuration.themeData, same(themeData));
    });

    test('should allow setting goldenDifferenceThreshold', () {
      final configuration = BcGoldenConfiguration();

      configuration.goldenDifferenceThreshold = 25.5;

      expect(configuration.goldenDifferenceThreshold, equals(25.5));
    });

    test('should allow setting willFailOnError', () {
      final configuration = BcGoldenConfiguration();

      configuration.willFailOnError = false;

      expect(configuration.willFailOnError, isFalse);
    });

    test('should maintain singleton state across property changes', () {
      final configuration1 = BcGoldenConfiguration();
      final configuration2 = BcGoldenConfiguration();

      configuration1.goldenDifferenceThreshold = 15;
      configuration1.willFailOnError = false;

      expect(configuration2.goldenDifferenceThreshold, equals(15));
      expect(configuration2.willFailOnError, isFalse);
    });

    test('should handle null themeProvider correctly', () {
      final configuration = BcGoldenConfiguration();

      configuration.themeProvider = null;

      expect(configuration.themeProvider, isNull);
    });

    test('should handle empty themeProvider list', () {
      final configuration = BcGoldenConfiguration();

      configuration.themeProvider = [];

      expect(configuration.themeProvider, isNotNull);
      expect(configuration.themeProvider, hasLength(0));
    });
  });

  group('loadConfiguration', () {
    test('should complete without throwing an exception', () async {
      expect(() async => await loadConfiguration(), returnsNormally);
    });

    test('should be callable multiple times', () async {
      await loadConfiguration();
      expect(() async => await loadConfiguration(), returnsNormally);
    });
  });
}
