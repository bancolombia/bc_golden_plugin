import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../capture/helpers.dart';
import '../config/bc_golden_configuration.dart';

/// ### LocalFileComparatorWithPixelTolerance
/// A golden file comparator that tolerates small per-pixel color
/// differences (see [pixelColorDelta]) before counting a pixel as a
/// mismatch, on top of the existing percentage [threshold].
///
/// This absorbs text antialiasing/hinting differences between font
/// rasterizers on different operating systems (e.g. a golden generated on
/// macOS/Windows compared against a CI run on Linux), which otherwise
/// inflate the reported diff percentage without there being a real visual
/// regression.
class LocalFileComparatorWithPixelTolerance extends LocalFileComparator {
  LocalFileComparatorWithPixelTolerance(
    super.testFile,
    this.threshold, {
    this.pixelColorDelta = 24,
  }) : assert(
          threshold >= 0 && threshold <= 1,
          'The threshold must be between 0 and 1',
        );

  final double threshold;

  final int pixelColorDelta;

  final int total = 100;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final Uint8List masterBytes =
        Uint8List.fromList(await getGoldenBytes(golden));

    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      masterBytes,
    );

    if (result.passed) {
      return true;
    }

    final double diffPercent = await _tolerantDiffPercent(
      imageBytes,
      masterBytes,
    );

    if (diffPercent <= threshold) {
      debugPrint(
        'A difference of ${diffPercent * total}% was found, but it is '
        'an acceptable value, given that the acceptance threshold is '
        '${threshold * total}%',
      );

      await generateFailureOutput(result, golden, basedir);

      return true;
    }

    if (BcGoldenConfiguration().willFailOnError) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }

    debugPrint(
      'A difference of ${diffPercent * total}% was found, but '
      'the willFailOnError option is set to false, so the test passes.',
    );

    return false;
  }

  /// Computes the percentage of pixels that differ by more than
  /// [pixelColorDelta] on any RGBA channel, ignoring smaller differences.
  Future<double> _tolerantDiffPercent(
    Uint8List testBytes,
    Uint8List masterBytes,
  ) async {
    final testImage = await decodeImageBytes(testBytes);
    final masterImage = await decodeImageBytes(masterBytes);

    if (testImage.width != masterImage.width ||
        testImage.height != masterImage.height) {
      return 1.0;
    }

    final testRgba = (await testImage.toByteData())!.buffer.asUint8List();
    final masterRgba = (await masterImage.toByteData())!.buffer.asUint8List();

    final totalPixels = testImage.width * testImage.height;
    var mismatches = 0;

    for (var i = 0; i < testRgba.length; i += 4) {
      final dr = (testRgba[i] - masterRgba[i]).abs();
      final dg = (testRgba[i + 1] - masterRgba[i + 1]).abs();
      final db = (testRgba[i + 2] - masterRgba[i + 2]).abs();
      final da = (testRgba[i + 3] - masterRgba[i + 3]).abs();

      if (dr > pixelColorDelta ||
          dg > pixelColorDelta ||
          db > pixelColorDelta ||
          da > pixelColorDelta) {
        mismatches++;
      }
    }

    return mismatches / totalPixels;
  }
}
