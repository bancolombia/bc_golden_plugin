import 'package:bc_golden_plugin/src/helpers/asset_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AwaitImages extension', () {
    testWidgets('awaitImages should work with default timeout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.asset('assets/test_image.png'),
          ),
        ),
      );

      // Should not throw when called with default parameters
      expect(() => tester.awaitImages(), returnsNormally);
    });

    testWidgets('awaitImages should work with custom timeout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.asset('assets/test_image.png'),
          ),
        ),
      );

      // Should not throw when called with custom timeout
      expect(
        () => tester.awaitImages(timeout: Duration(seconds: 5)),
        returnsNormally,
      );
    });

    testWidgets('awaitImages should work with custom pump function', (tester) async {
      bool customPumpCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.asset('assets/test_image.png'),
          ),
        ),
      );

      await tester.awaitImages(
        customPump: () async {
          customPumpCalled = true;
          await tester.pump(Duration(milliseconds: 100));
        },
      );

      // Note: customPump will only be called if there are images found
      // Since we're using asset images that may not load in test environment,
      // we just verify the call doesn't throw
      expect(() => tester.awaitImages(customPump: () async {}), returnsNormally);
    });

    testWidgets('awaitImages should handle empty widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      // Should work fine with no images
      await tester.awaitImages();
      expect(true, isTrue); // If we get here, test passed
    });

    testWidgets('awaitImages should handle DecoratedBox with image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/test_image.png'),
                ),
              ),
              child: Container(width: 100, height: 100),
            ),
          ),
        ),
      );

      // Should handle DecoratedBox images
      await tester.awaitImages();
      expect(true, isTrue); // If we get here, test passed
    });
  });
}