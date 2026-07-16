// ignore_for_file: non_constant_identifier_names, test_reflective_loader requires test_-prefixed names
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bc_golden_lint/src/rules/prefer_bc_golden_capture.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferBcGoldenCaptureTest);
  });
}

@reflectiveTest
class PreferBcGoldenCaptureTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferBcGoldenCapture();
    super.setUp();
  }

  Future<void> test_bcGoldenTestCall() async {
    await assertDiagnostics(
      r'''
void bcGoldenTest(String description, Function test) {}

void f() {
  bcGoldenTest('a golden test', () {});
}
''',
      [lint(70, 12)],
    );
  }

  Future<void> test_bcGoldenCaptureSingleIsIgnored() async {
    await assertNoDiagnostics(r'''
class BcGoldenCapture {
  static void single(String description, Function test) {}
}

void f() {
  BcGoldenCapture.single('a golden test', () {});
}
''');
  }
}
