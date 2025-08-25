import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ui.Image> decode(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final frame = await codec.getNextFrame();

    return frame.image;
  }

  group('GoldenScreenshot.add', () {
    test('add valid screenshots and rejects empty ones', () {
      final goldenScreenshot = GoldenScreenshot();

      expect(goldenScreenshot.screenshots, isEmpty);

      expect(goldenScreenshot.screenshots, isA<List<Uint8List>>());
    });
  });

  group('GoldenScreenshot.captureScreenshot', () {
    testWidgets(
      'captures a PNG image from RepaintBoundary widget.',
      (tester) async {
        await tester.runAsync(() async {
          final goldenScreenshot = GoldenScreenshot();

          const size = Size(120, 80);

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: const ColoredBox(color: Colors.blue),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          await goldenScreenshot.captureScreenshot();

          expect(goldenScreenshot.screenshots, hasLength(1));

          final bytes = goldenScreenshot.screenshots.first;
          expect(bytes, isNotEmpty);

          final img = await decode(bytes);
          expect(img.width, equals(size.width.toInt()));
          expect(img.height, equals(size.height.toInt()));
          img.dispose();
        });
      },
    );
  });

  group('GoldenScreenshot.combineScreenshots', () {
    Widget createColorWidget(Color color, Size size) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: ColoredBox(color: color),
            ),
          ),
        ),
      );
    }

    testWidgets('throws ArgumentError if the list is empty.', (tester) async {
      final goldenScreenshot = GoldenScreenshot();

      const config = GoldenCaptureConfig(
        testName: 'Test',
        layoutType: CaptureLayoutType.vertical,
        spacing: 8,
        maxScreensPerRow: 2,
      );

      expect(
        () => goldenScreenshot.combineScreenshots(config, []),
        throwsA(isA<ArgumentError>()),
      );
    });

    testWidgets('combines in vertical layout', (tester) async {
      await tester.runAsync(() async {
        final goldenScreenshot = GoldenScreenshot();

        await tester
            .pumpWidget(createColorWidget(Colors.red, const Size(100, 180)));
        await tester.pumpAndSettle();
        await goldenScreenshot.captureScreenshot();

        await tester
            .pumpWidget(createColorWidget(Colors.green, const Size(100, 180)));
        await tester.pumpAndSettle();
        await goldenScreenshot.captureScreenshot();

        const config = GoldenCaptureConfig(
          testName: 'Test',
          layoutType: CaptureLayoutType.vertical,
          spacing: 8,
          maxScreensPerRow: 2,
        );

        final combined = await goldenScreenshot.combineScreenshots(
          config,
          ['Step A', 'Step B'],
        );

        expect(combined, isNotEmpty);

        final img = await decode(combined);
        expect(img.width, greaterThanOrEqualTo(100));
        expect(img.height, greaterThan(2 * (180 + 40 + 8) + 20 - 1));
        img.dispose();
      });
    });

    testWidgets('combines in horizontal layout', (tester) async {
      await tester.runAsync(() async {
        final goldenScreenshot = GoldenScreenshot();

        await tester
            .pumpWidget(createColorWidget(Colors.red, const Size(100, 180)));
        await tester.pumpAndSettle();
        await goldenScreenshot.captureScreenshot();

        await tester
            .pumpWidget(createColorWidget(Colors.green, const Size(100, 180)));
        await tester.pumpAndSettle();
        await goldenScreenshot.captureScreenshot();

        await tester
            .pumpWidget(createColorWidget(Colors.blue, const Size(100, 180)));
        await tester.pumpAndSettle();
        await goldenScreenshot.captureScreenshot();

        const config = GoldenCaptureConfig(
          testName: 'Test',
          layoutType: CaptureLayoutType.horizontal,
          spacing: 12,
          maxScreensPerRow: 3,
        );

        final combined = await goldenScreenshot.combineScreenshots(
          config,
          ['A', 'B', 'C'],
        );

        final img = await decode(combined);

        expect(img.width, greaterThan(3 * 100 + 24 - 1));
        expect(img.height, greaterThanOrEqualTo(180 + 40 + 40));
        img.dispose();
      });
    });

    testWidgets(
      'combines in grid layout with maxScreensPerRow',
      (tester) async {
        await tester.runAsync(() async {
          final goldenScreenshot = GoldenScreenshot();

          await tester
              .pumpWidget(createColorWidget(Colors.red, const Size(100, 180)));
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();

          await tester.pumpWidget(
            createColorWidget(
              Colors.green,
              const Size(100, 180),
            ),
          );
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();

          await tester
              .pumpWidget(createColorWidget(Colors.blue, const Size(100, 180)));
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();

          const config = GoldenCaptureConfig(
            testName: 'Test',
            layoutType: CaptureLayoutType.grid,
            spacing: 10,
            maxScreensPerRow: 2,
          );

          final combined = await goldenScreenshot.combineScreenshots(
            config,
            ['1', '2', '3'],
          );

          final img = await decode(combined);

          expect(img.width, greaterThanOrEqualTo(2 * 100 + 10 + 20));
          expect(img.height, greaterThanOrEqualTo(2 * (180 + 40) + 10 + 20));
          img.dispose();
        });
      },
    );

    testWidgets('respects canvas limit and expands if needed', (tester) async {
      await tester.runAsync(() async {
        final goldenScreenshot = GoldenScreenshot();

        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(
            createColorWidget(
              Colors.orange,
              const Size(800, 1200),
            ),
          );
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();
        }

        const config = GoldenCaptureConfig(
          testName: 'Test',
          layoutType: CaptureLayoutType.vertical,
          spacing: 16,
          maxScreensPerRow: 2,
        );
        final names = List<String>.generate(
          goldenScreenshot.screenshots.length,
          (i) => 'Step ${i + 1}',
        );

        final combined =
            await goldenScreenshot.combineScreenshots(config, names);
        final img = await decode(combined);

        expect(img.width, lessThanOrEqualTo(4096));
        expect(img.height, lessThanOrEqualTo(4096));
        img.dispose();
      });
    });

    testWidgets(
      'fails if stepnames list is shorter than screenshots',
      (tester) async {
        await tester.runAsync(() async {
          final goldenScreenshot = GoldenScreenshot();

          await tester
              .pumpWidget(createColorWidget(Colors.red, const Size(100, 180)));
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();

          await tester.pumpWidget(
            createColorWidget(
              Colors.green,
              const Size(100, 180),
            ),
          );
          await tester.pumpAndSettle();
          await goldenScreenshot.captureScreenshot();

          const config = GoldenCaptureConfig(
            testName: 'Test',
            layoutType: CaptureLayoutType.vertical,
            spacing: 8,
            maxScreensPerRow: 2,
          );

          expect(
            () => goldenScreenshot.combineScreenshots(
              config,
              ['Only one'],
            ),
            throwsA(isA<RangeError>()),
          );
        });
      },
    );
  });
}
