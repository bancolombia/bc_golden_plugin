import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../golden_configuration.dart';

/// ### LocalFileComparatorWithThreshold
/// This class is intended to use a custom value of difference acceptance
/// so it will take the path to the test and if the value is more than
/// [_kGoldenTestsThreshold] it will fail the test.

// coverage:ignore-start
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  final double threshold;

  LocalFileComparatorWithThreshold(Uri testFile, this.threshold)
      : assert(threshold >= 0 && threshold <= 1),
        super(testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      debugPrint(
        'Se encontró una diferencia de ${result.diffPercent * 100}%, pero es '
        'un valor aceptable, dado que el porcentaje de aceptación es de '
        '${threshold * 100}%',
      );

      await generateFailureOutput(result, golden, basedir);

      return true;
    }

    if (!result.passed && bcGoldenConfiguration.getWillFailOnError) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }

    debugPrint(
      'Se encontró una diferencia de ${result.diffPercent * 100}%, pero  '
      'la opción willFailOnError está en false por lo tanto el test pasa.',
    );
    return !result.passed;
  }
}

BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

/// This is the constant value of the minimum percent of difference in
/// a test.
double _kGoldenTestsThreshold =
    bcGoldenConfiguration.getGoldenDifferenceThreshold / 100;

Future<void> localFileComparator(String testUrl) async {
  final String fileName = testUrl.split('/').last;

  if (goldenFileComparator is LocalFileComparator) {
    goldenFileComparator = LocalFileComparatorWithThreshold(
        Uri.parse('$testUrl/$fileName' '_golden_test.dart'),
        _kGoldenTestsThreshold);
  } else {
    throw Exception(
      goldenFileComparator.runtimeType,
    );
  }
}
// coverage:ignore-end
