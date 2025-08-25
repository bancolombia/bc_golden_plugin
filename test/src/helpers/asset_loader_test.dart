import 'package:bc_golden_plugin/src/helpers/asset_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<AssetBundle>(),
])
void main() {
  group('AssetLoader Extension', () {
    testWidgets(
      'awaitImages should handle widgets without images gracefully',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Hello World'),
                  Icon(Icons.star),
                ],
              ),
            ),
          ),
        );

        await tester.awaitImages();

        expect(find.text('Hello World'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      },
    );

    testWidgets(
      'awaitImages should handle DecoratedBox without image decoration',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Test'),
              ),
            ),
          ),
        );

        await tester.awaitImages();

        expect(find.byType(DecoratedBox), findsOneWidget);
      },
    );

    testWidgets('awaitImages should handle empty widget tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('No images here'),
          ),
        ),
      );

      await tester.awaitImages();

      expect(find.byType(Image), findsNothing);
    });

    testWidgets(
      'awaitImages should handle icons and built-in assets',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Icon(Icons.home),
                  Icon(Icons.settings),
                ],
              ),
            ),
          ),
        );

        await tester.awaitImages();

        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
      },
    );

    testWidgets(
      'awaitImages should handle real project assets',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Image.asset('assets/LogoBancolombia.png'),
            ),
          ),
        );

        await tester.awaitImages();

        expect(find.byType(Image), findsOneWidget);
      },
    );
  });

  group('loadMaterialIconFont', () {
    test('should be callable without throwing an exception', () {
      expect(() => loadMaterialIconFont(), returnsNormally);
    });
  });

  group('loadAppFonts', () {
    test('should be callable without throwing an exception', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      expect(() => loadAppFonts(), returnsNormally);
    });
  });

  group('derivedFontFamily', () {
    test('should return empty string when font definition has no family', () {
      const fontDefinition = <String, dynamic>{};

      final result = derivedFontFamily(fontDefinition);

      expect(result, isEmpty);
    });

    test('should return original family name for overridable fonts', () {
      const fontDefinition = <String, dynamic>{
        'family': 'Roboto',
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('Roboto'));
    });

    test('should handle packages/ prefix in font family', () {
      const fontDefinition = <String, dynamic>{
        'family': 'packages/my_package/CustomFont',
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('packages/my_package/CustomFont'));
    });

    test(
      'should extract font family name from packages/ prefix when it matches overridable fonts',
      () {
        const fontDefinition = <String, dynamic>{
          'family': 'packages/some_package/Roboto',
        };

        final result = derivedFontFamily(fontDefinition);

        expect(result, equals('Roboto'));
      },
    );

    test('should add package prefix when font asset starts with packages', () {
      const fontDefinition = <String, dynamic>{
        'family': 'CustomFont',
        'fonts': [
          {
            'asset': 'packages/my_package/fonts/CustomFont.ttf',
          },
        ],
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('packages/my_package/CustomFont'));
    });

    test(
      'should return original family name when no special conditions apply',
      () {
        const fontDefinition = <String, dynamic>{
          'family': 'MyCustomFont',
          'fonts': [
            {
              'asset': 'fonts/MyCustomFont.ttf',
            },
          ],
        };

        final result = derivedFontFamily(fontDefinition);

        expect(result, equals('MyCustomFont'));
      },
    );

    test('should handle font definition with multiple font types', () {
      const fontDefinition = <String, dynamic>{
        'family': 'MultiFont',
        'fonts': [
          {
            'asset': 'fonts/MultiFont-Regular.ttf',
          },
          {
            'asset': 'packages/my_package/fonts/MultiFont-Bold.ttf',
          },
        ],
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('packages/my_package/MultiFont'));
    });

    test('should handle null asset in font types', () {
      const fontDefinition = <String, dynamic>{
        'family': 'TestFont',
        'fonts': [
          {
            'asset': null,
          },
          {
            'asset': 'fonts/TestFont.ttf',
          },
        ],
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('TestFont'));
    });

    test('should prioritize first packages asset found', () {
      const fontDefinition = <String, dynamic>{
        'family': 'TestFont',
        'fonts': [
          {
            'asset': 'packages/first_package/fonts/TestFont.ttf',
          },
          {
            'asset': 'packages/second_package/fonts/TestFont.ttf',
          },
        ],
      };

      final result = derivedFontFamily(fontDefinition);

      expect(result, equals('packages/first_package/TestFont'));
    });
  });
}
