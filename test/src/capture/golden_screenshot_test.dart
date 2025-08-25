import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:bc_golden_plugin/src/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> pngOf({
    required int width,
    required int height,
    Color color = const Color(0xFF00FF00),
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    picture.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert image to PNG');
    }
    return byteData.buffer.asUint8List();
  }

  Future<ui.Image> decode(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final frame = await codec.getNextFrame();

    return frame.image;
  }

  group('GoldenScreenshot.add', () {
    test('add valid screenshots and rejects empty ones', () {
      final goldenScreenshot = GoldenScreenshot();

      goldenScreenshot.add(Uint8List(0));
      expect(goldenScreenshot.screenshots, isEmpty);

      goldenScreenshot.add(Uint8List.fromList([1, 2, 3]));
      expect(goldenScreenshot.screenshots, hasLength(1));

      goldenScreenshot.add(Uint8List.fromList([4, 5]));
      expect(goldenScreenshot.screenshots, hasLength(2));
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

          final bytes = await goldenScreenshot.captureScreenshot();
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
    late Uint8List shotA;
    late Uint8List shotB;
    late Uint8List shotC;

    setUp(() async {
      shotA =
          await pngOf(width: 100, height: 180, color: const Color(0xFFFF0000));
      shotB =
          await pngOf(width: 100, height: 180, color: const Color(0xFF00FF00));
      shotC =
          await pngOf(width: 100, height: 180, color: const Color(0xFF0000FF));
    });

    test('throws ArgumentError if the list is empty.', () async {
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

    test('combines in vertical layout', () async {
      final goldenScreenshot = GoldenScreenshot();

      goldenScreenshot.addAll([
        shotA,
        shotB,
      ]);

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

    test('combines in horizontal layout', () async {
      final goldenScreenshot = GoldenScreenshot();

      goldenScreenshot.addAll([
        shotA,
        shotB,
        shotC,
      ]);

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

    test('combines in grid layout with maxScreensPerRow', () async {
      final goldenScreenshot = GoldenScreenshot();

      goldenScreenshot.addAll([
        shotA,
        shotB,
        shotC,
      ]);

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

    test('respects canvas limit and expands if needed', () async {
      final goldenScreenshot = GoldenScreenshot();
      for (int i = 0; i < 30; i++) {
        goldenScreenshot.add(await pngOf(width: 800, height: 1200));
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

      final combined = await goldenScreenshot.combineScreenshots(config, names);
      final img = await decode(combined);

      expect(img.width, lessThanOrEqualTo(4096));
      expect(img.height, lessThanOrEqualTo(4096));
      img.dispose();
    });

    test(
      'fails if stepnames list is shorter than screenshots',
      () async {
        final goldenScreenshot = GoldenScreenshot();

        goldenScreenshot.addAll([
          shotA,
          shotB,
        ]);

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
      },
    );
  });
}
