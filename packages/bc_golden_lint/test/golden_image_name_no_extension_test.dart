// ignore_for_file: non_constant_identifier_names, test_reflective_loader requires test_-prefixed names
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:bc_golden_lint/src/rules/golden_image_name_no_extension.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(GoldenImageNameNoExtensionTest);
  });
}

@reflectiveTest
class GoldenImageNameNoExtensionTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = GoldenImageNameNoExtension();
    super.setUp();
  }

  Future<void> test_imageNameWithPngExtension() async {
    await assertDiagnostics(
      r'''
Future<void> bcWidgetMatchesImage({required String imageName}) async {}

void f() {
  bcWidgetMatchesImage(imageName: 'home.png');
}
''',
      [lint(118, 10)],
    );
  }

  Future<void> test_imageNameWithoutExtension() async {
    await assertNoDiagnostics(r'''
Future<void> bcWidgetMatchesImage({required String imageName}) async {}

void f() {
  bcWidgetMatchesImage(imageName: 'home');
}
''');
  }

  Future<void> test_unrelatedCallIsIgnored() async {
    await assertNoDiagnostics(r'''
void bcWidgetMatchesImage({required String imageName}) {}

void f() {
  someOtherFunction(imageName: 'home.png');
}

void someOtherFunction({required String imageName}) {}
''');
  }
}
