import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../config/bc_golden_configuration.dart';

/// ### LocalFileComparatorWithThreshold
/// A [LocalFileComparator] that accepts a configurable difference between the
/// rendered image and the golden. If the difference is below [threshold]
/// (a ratio in the range `0..1`), the comparison passes.
///
/// This comparator only customizes the *comparison* ([compare]). The
/// *generation* of goldens ([update], used with `--update-goldens`) always
/// writes the current render as-is; the [threshold] does NOT apply when
/// updating. [update] is overridden here only to document that contract
/// explicitly and to keep behavior consistent if the base implementation
/// changes.
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  LocalFileComparatorWithThreshold(
    super.testFile,
    this.threshold,
  ) : assert(
          threshold >= 0 && threshold <= 1,
          'The threshold must be between 0 and 1',
        );

  final double threshold;

  /// Multiplier used to express [ComparisonResult.diffPercent] and [threshold]
  /// as human-readable percentages in log messages.
  static const int _percentBase = 100;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed) {
      return true;
    }

    if (result.diffPercent <= threshold) {
      debugPrint(
        'A difference of ${result.diffPercent * _percentBase}% was found, but '
        'it is an acceptable value, given that the acceptance threshold is '
        '${threshold * _percentBase}%',
      );

      if (bcGoldenConfiguration.shouldCreateFailuresFolder) {
        await generateFailureOutput(result, golden, basedir);
      }

      return true;
    }

    if (bcGoldenConfiguration.willFailOnError) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }

    debugPrint(
      'A difference of ${result.diffPercent * _percentBase}% was found, but '
      'the willFailOnError option is set to false, so the test passes.',
    );

    return !result.passed;
  }

  /// Writes [imageBytes] as the new golden at [golden].
  ///
  /// Invoked by the framework when tests run with `--update-goldens`. The
  /// [threshold] intentionally does not participate here: updating always
  /// stores the current render verbatim. This override delegates to the base
  /// implementation and exists to make that contract explicit.
  @override
  Future<void> update(Uri golden, Uint8List imageBytes) {
    return super.update(golden, imageBytes);
  }
}

BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

/// Installs a [LocalFileComparatorWithThreshold] as the active
/// [goldenFileComparator], using the tolerance configured in
/// [BcGoldenConfiguration.goldenDifferenceRatio].
///
/// [testUrl] is the path to the current test file (or its directory). The
/// golden comparator resolves golden paths relative to the test file's
/// directory, so the file name is preserved and joined using [p.join] instead
/// of string concatenation for robustness across platforms.
Future<void> localFileComparator(String testUrl) async {
  if (goldenFileComparator is! LocalFileComparator) {
    throw Exception(goldenFileComparator.runtimeType);
  }

  final Uri testUri = _resolveTestFileUri(testUrl);

  goldenFileComparator = LocalFileComparatorWithThreshold(
    testUri,
    bcGoldenConfiguration.goldenDifferenceRatio,
  );
}

/// Builds a robust [Uri] pointing to the test file used as the base for
/// resolving golden paths.
///
/// Accepts either a path to a `*_test.dart` file or a directory. When given a
/// directory, a synthetic `_golden_test.dart` file name is appended so the
/// comparator's `basedir` resolves to that directory. Path components are
/// joined with [p.join] to avoid the fragile string concatenation used
/// previously.
///
/// Prefer passing a native file path (e.g. from [Uri.toFilePath]). URI-style
/// paths such as `/C:/...` (the result of [Uri.path] on Windows) are also
/// accepted via a [Uri.parse] fallback, since [Uri.file] rejects them.
Uri _resolveTestFileUri(String testUrl) {
  final bool looksLikeDartFile = testUrl.endsWith('.dart');

  if (looksLikeDartFile) {
    return _uriFromPath(testUrl);
  }

  final String fileName = p.basename(testUrl);
  final String syntheticTestFile =
      p.join(testUrl, '${fileName}_golden_test.dart');

  return _uriFromPath(syntheticTestFile);
}

Uri _uriFromPath(String path) {
  try {
    return Uri.file(path);
  } on ArgumentError {
    // Windows [Uri.path] values look like `/C:/...` and are rejected by
    // [Uri.file]; [Uri.parse] accepts that form.
    return Uri.parse(path);
  }
}
