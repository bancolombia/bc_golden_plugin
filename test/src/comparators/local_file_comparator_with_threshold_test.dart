//ignore_for_file: missing-test-assertion, prefer-correct-identifier-length, avoid-ignoring-return-values
import 'dart:io';

import 'package:bc_golden_plugin/src/comparators/local_file_comparator_with_threshold.dart';
import 'package:file/memory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late LocalFileComparatorWithThreshold localFileComparatorWithThreshold;
  late MemoryFileSystem fileSystem;

  String fix(String path) {
    String temp = path;

    if (temp.startsWith('/')) {
      temp = '${fileSystem.style.drive}$path';
    }

    return temp.replaceAll('/', fileSystem.path.separator);
  }

  setUp(() {
    final FileSystemStyle style =
        Platform.isWindows ? FileSystemStyle.windows : FileSystemStyle.posix;

    fileSystem = MemoryFileSystem(style: style);
    localFileComparatorWithThreshold = LocalFileComparatorWithThreshold(
      fileSystem.file(fix('/golden_test.dart')).uri,
      1.0,
    );
  });
  group('goldenFileComparator', () {
    test('is initialized by test framework', () {
      expect(localFileComparatorWithThreshold, isNotNull);
      expect(localFileComparatorWithThreshold, isA<LocalFileComparator>());
    });

    test('calculates basedir correctly', () {
      expect(
        localFileComparatorWithThreshold.basedir,
        fileSystem.file(fix('/')).uri,
      );
      localFileComparatorWithThreshold = LocalFileComparatorWithThreshold(
        fileSystem.file(fix('/foo/bar/golden_test.dart')).uri,
        1,
      );
      expect(
        localFileComparatorWithThreshold.basedir,
        fileSystem.directory(fix('/foo/bar/')).uri,
      );
    });

    test('throws if local output is not awaited', () {
      try {
        localFileComparatorWithThreshold.generateFailureOutput(
          ComparisonResult(
            passed: false,
            diffPercent: 1.0,
          ),
          Uri.parse(
            'foo_test.dart',
          ),
          Uri.parse(
            '/foo/bar/',
          ),
        );
        TestAsyncUtils.verifyAllScopesClosed();
        fail('unexpectedly did not throw');
      } on FlutterError catch (e) {
        final List<String> lines = e.message.split('\n');
        expectSync(
          lines.firstOrNull,
          'Asynchronous call to guarded function leaked.',
        );
        expectSync(
          lines[1],
          'You must use "await" with all Future-returning test APIs.',
        );

        expectSync(lines.length, 3);
        final DiagnosticPropertiesBuilder propertiesBuilder =
            DiagnosticPropertiesBuilder();
        e.debugFillProperties(propertiesBuilder);
        final List<DiagnosticsNode> information = propertiesBuilder.properties;
        expectSync(information.length, 3);
        expectSync(
          information.firstOrNull?.level,
          DiagnosticLevel.summary,
        );
        expectSync(information[1].level, DiagnosticLevel.hint);
        expectSync(information[2].level, DiagnosticLevel.info);
      }
    });

    test(
      'goldenFileComparator should be changed to LocalFileComparatorWithThreshold',
      () {
        localFileComparator(
          'foo_test.dart',
        );

        expect(goldenFileComparator, isA<LocalFileComparatorWithThreshold>());
      },
    );
  });

  group('image comparisons', () {
    Uint8List pngSolid(int n, int r, int g, int b) {
      final im = img.Image(width: n, height: n);
      for (var y = 0; y < n; y++) {
        for (var x = 0; x < n; x++) {
          im.setPixelRgba(x, y, r, g, b, 255);
        }
      }

      return Uint8List.fromList(img.encodePng(im));
    }

    Uint8List pngWithKDiffs({
      required int n,
      required int r1,
      required int g1,
      required int b1,
      required int r2,
      required int g2,
      required int b2,
      required int k,
    }) {
      final im = img.Image(width: n, height: n);
      for (var y = 0; y < n; y++) {
        for (var x = 0; x < n; x++) {
          im.setPixelRgba(x, y, r1, g1, b1, 255);
        }
      }
      var changed = 0;
      for (var y = 0; y < n && changed < k; y++) {
        for (var x = 0; x < n && changed < k; x++) {
          im.setPixelRgba(x, y, r2, g2, b2, 255);
          changed++;
        }
      }

      return Uint8List.fromList(img.encodePng(im));
    }

    late Directory tmp;
    late LocalFileComparatorWithThreshold comparator;

    setUpAll(() {
      tmp = Directory.systemTemp.createTempSync('goldens_test_');
      File('${tmp.path}/black.png').writeAsBytesSync(
        pngSolid(10, 0, 0, 0),
      );
      File('${tmp.path}/white.png').writeAsBytesSync(
        pngSolid(10, 255, 255, 255),
      );

      comparator = LocalFileComparatorWithThreshold(
        Uri.file('${tmp.path}/dummy_base_test.dart'),
        0.1,
      );
    });

    test('compare returns true for acceptable difference (<10%)', () async {
      final Uri goldenUri = Uri.file('${tmp.path}/black.png');

      final Uint8List imageBytes = pngWithKDiffs(
        n: 10,
        r1: 0,
        g1: 0,
        b1: 0,
        r2: 10,
        g2: 10,
        b2: 10,
        k: 5,
      );

      final result = await comparator.compare(imageBytes, goldenUri);
      expect(result, isTrue);
    });

    test(
      'unacceptable difference (>10%) retorna false y loguea por debugPrint',
      () async {
        final goldenUri = Uri.file('${tmp.path}/black.png');
        final imgBytes = pngWithKDiffs(
          n: 10,
          r1: 0, g1: 0, b1: 0,
          r2: 255, g2: 255, b2: 255,
          k: 10, // 20/100 = 20%
        );

        final logs = <String>[];
        final oldDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };
        addTearDown(() => debugPrint = oldDebugPrint);

        final ok = await comparator.compare(imgBytes, goldenUri);
        expect(ok, isTrue);

        expect(
          logs.join('\n'),
          anyOf(
            contains('A difference of'),
            contains('Pixel test failed'),
          ),
        );
      },
    );

    test(
      'compare logs acceptable difference (no throw)',
      () async {
        final Uri goldenUri = Uri.file('${tmp.path}/white.png');

        final Uint8List imageBytes = pngWithKDiffs(
          n: 10,
          r1: 255,
          g1: 255,
          b1: 255,
          r2: 240,
          g2: 240,
          b2: 240,
          k: 5,
        );

        await comparator.compare(imageBytes, goldenUri);
      },
    );

    test(
      'localFileComparator initializes LocalFileComparatorWithThreshold',
      () async {
        await localFileComparator('foo_test.dart');
        expect(
          goldenFileComparator,
          isA<LocalFileComparatorWithThreshold>(),
        );
      },
    );
  });
}
