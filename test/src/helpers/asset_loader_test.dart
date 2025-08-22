import 'package:bc_golden_plugin/src/helpers/asset_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetLoader extension', () {
    testWidgets('awaitImages() works without parameters (backward compatibility)', (tester) async {
      // Build a simple widget with an image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.star),
          ),
        ),
      );
      
      // This should not throw and should complete successfully
      await tester.awaitImages();
      
      expect(find.byType(Icon), findsOneWidget);
    });
    
    testWidgets('awaitImages() works with timeout parameter', (tester) async {
      // Build a simple widget with an image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.star),
          ),
        ),
      );
      
      // This should not throw and should complete successfully with custom timeout
      await tester.awaitImages(timeout: const Duration(seconds: 5));
      
      expect(find.byType(Icon), findsOneWidget);
    });
    
    testWidgets('awaitImages() works with duration parameter', (tester) async {
      // Build a simple widget with an image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.star),
          ),
        ),
      );
      
      // This should not throw and should complete successfully with custom duration
      await tester.awaitImages(duration: const Duration(milliseconds: 100));
      
      expect(find.byType(Icon), findsOneWidget);
    });
    
    testWidgets('awaitImages() works with both timeout and duration parameters', (tester) async {
      // Build a simple widget with an image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.star),
          ),
        ),
      );
      
      // This should not throw and should complete successfully with both parameters
      await tester.awaitImages(
        timeout: const Duration(seconds: 5),
        duration: const Duration(milliseconds: 100),
      );
      
      expect(find.byType(Icon), findsOneWidget);
    });
    
    testWidgets('awaitImages() handles Image widgets', (tester) async {
      // Build a widget with an Image
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.asset(
              'assets/test_image.png',
              // Use an error widget to avoid actual asset loading issues in tests
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
          ),
        ),
      );
      
      // This should not throw even with an image that doesn't exist
      await tester.awaitImages(timeout: const Duration(seconds: 1));
      
      // Should find either the image or the error icon
      expect(find.byType(Image).evaluate().isNotEmpty || find.byType(Icon).evaluate().isNotEmpty, isTrue);
    });
    
    testWidgets('awaitImages() handles DecoratedBox with background images', (tester) async {
      // Build a widget with a DecoratedBox containing an image decoration
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/test_image.png'),
                  onError: (exception, stackTrace) {
                    // Handle error to avoid test failures
                  },
                ),
              ),
              child: const Text('Test'),
            ),
          ),
        ),
      );
      
      // This should not throw even with an image that doesn't exist
      await tester.awaitImages(timeout: const Duration(seconds: 1));
      
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}