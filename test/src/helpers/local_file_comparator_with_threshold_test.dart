import 'package:bc_golden_plugin/src/helpers/local_file_comparator_with_threshold.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

void main() {
  late LocalFileComparatorWithThreshold localFileComparatorWithThreshold;
  late MemoryFileSystem fs;

  String fix(String path) {
    if (path.startsWith('/')) {
      path = '${fs.style.drive}$path';
    }
    return path.replaceAll('/', fs.path.separator);
  }

  setUp(() {
    final FileSystemStyle style =
        io.Platform.isWindows ? FileSystemStyle.windows : FileSystemStyle.posix;

    fs = MemoryFileSystem(style: style);
    localFileComparatorWithThreshold = LocalFileComparatorWithThreshold(
        fs.file(fix('/golden_test.dart')).uri, 1.0);
  });
  group('goldenFileComparator', () {
    test('is initialized by test framework', () {
      expect(localFileComparatorWithThreshold, isNotNull);
      expect(localFileComparatorWithThreshold, isA<LocalFileComparator>());
    });

    test('calculates basedir correctly', () {
      expect(localFileComparatorWithThreshold.basedir, fs.file(fix('/')).uri);
      localFileComparatorWithThreshold = LocalFileComparatorWithThreshold(
          fs.file(fix('/foo/bar/golden_test.dart')).uri, 1);
      expect(localFileComparatorWithThreshold.basedir,
          fs.directory(fix('/foo/bar/')).uri);
    });

    test('throws if local output is not awaited', () {
      try {
        localFileComparatorWithThreshold.generateFailureOutput(
          ComparisonResult(passed: false, diffPercent: 1.0),
          Uri.parse('foo_test.dart'),
          Uri.parse('/foo/bar/'),
        );
        TestAsyncUtils.verifyAllScopesClosed();
        fail('unexpectedly did not throw');
      } on FlutterError catch (e) {
        final List<String> lines = e.message.split('\n');
        expectSync(lines[0], 'Asynchronous call to guarded function leaked.');
        expectSync(lines[1],
            'You must use "await" with all Future-returning test APIs.');

        expectSync(lines.length, 3);
        final DiagnosticPropertiesBuilder propertiesBuilder =
            DiagnosticPropertiesBuilder();
        e.debugFillProperties(propertiesBuilder);
        final List<DiagnosticsNode> information = propertiesBuilder.properties;
        expectSync(information.length, 3);
        expectSync(information[0].level, DiagnosticLevel.summary);
        expectSync(information[1].level, DiagnosticLevel.hint);
        expectSync(information[2].level, DiagnosticLevel.info);
      }
    });
  });
}
