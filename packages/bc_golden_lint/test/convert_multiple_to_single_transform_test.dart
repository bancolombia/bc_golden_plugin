import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:bc_golden_lint/src/assists/convert_multiple_to_single_transform.dart';
import 'package:test/test.dart';

MethodInvocation _findMultipleInvocation(String source) {
  final unit = parseString(content: source).unit;
  MethodInvocation? found;
  unit.accept(_MultipleVisitor((node) => found = node));
  return found!;
}

class _MultipleVisitor extends RecursiveAstVisitor<void> {
  _MultipleVisitor(this.onFound);
  final void Function(MethodInvocation) onFound;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'multiple') onFound(node);
    super.visitMethodInvocation(node);
  }
}

void main() {
  group('extractMultipleCall', () {
    test('returns null when steps is not a literal list', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple('desc', someExternalStepsList, config);
}
''';
      final invocation = _findMultipleInvocation(source);
      expect(extractMultipleCall(invocation), isNull);
    });

    test('returns null when the steps list contains a spread', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'desc',
    [
      GoldenStep(stepName: 'a', widgetBuilder: () => const HomePage()),
      ...extraSteps,
    ],
    GoldenCaptureConfig(testName: 'x'),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      expect(extractMultipleCall(invocation), isNull);
    });

    test('extracts steps, device, and per-step actions', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'Multiple test',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(title: 'Flutter Demo Home Page'),
      ),
      GoldenStep(
        stepName: 'home 2',
        widgetBuilder: () => HomePage(
          title: 'Page 1',
          backgroundColor: Colors.red[100],
        ),
      ),
      GoldenStep(
        stepName: 'Another page',
        widgetBuilder: () => const AnotherPage(),
      ),
    ],
    GoldenCaptureConfig(
      testName: 'multiple_screens',
      device: GoldenDeviceData.iPhone13,
      spacing: 100,
    ),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation);

      expect(extracted, isNotNull);
      expect(extracted!.steps, hasLength(3));
      expect(extracted.steps[0].stepNameLiteral, 'home');
      expect(extracted.steps[1].stepNameLiteral, 'home 2');
      expect(extracted.steps[2].stepNameLiteral, 'Another page');
      expect(
        extracted.steps[2].widgetSource,
        'const AnotherPage()',
      );
      expect(extracted.deviceSource, 'GoldenDeviceData.iPhone13');
    });

    test('extracts setupAction and verifyAction when present', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'desc',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(),
        setupAction: (tester) async { await tester.tap(find.text('go')); },
        verifyAction: (tester) async { expect(find.text('done'), findsOneWidget); },
      ),
    ],
    GoldenCaptureConfig(testName: 'x'),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation)!;

      expect(extracted.steps.single.setupActionSource, isNotNull);
      expect(extracted.steps.single.verifyActionSource, isNotNull);
    });

    test('keeps a multi-statement widgetBuilder as an IIFE', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'desc',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () {
          final controller = TextEditingController();
          return HomePage(controller: controller);
        },
      ),
    ],
    GoldenCaptureConfig(testName: 'x'),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation)!;

      expect(extracted.steps.single.widgetSource, startsWith('(() {'));
      expect(extracted.steps.single.widgetSource, endsWith('})()'));
    });
  });

  group('generateSingleTestsSource', () {
    test('produces one BcGoldenCapture.single call per step', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'Multiple test',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(title: 'A'),
      ),
      GoldenStep(
        stepName: 'home 2',
        widgetBuilder: () => HomePage(title: 'B'),
      ),
    ],
    GoldenCaptureConfig(
      testName: 'basic',
      device: GoldenDeviceData.iPhone13,
    ),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation)!;
      final generated = generateSingleTestsSource(extracted);

      expect(
        'BcGoldenCapture.single('.allMatches(generated).length,
        2,
      );
      expect(generated, contains("imageName: 'home',"));
      expect(generated, contains("imageName: 'home_2',"));
      expect(generated, contains('device: GoldenDeviceData.iPhone13,'));
      expect(generated, contains('widget: const HomePage(title: \'A\'),'));
      expect(generated, contains('widget: HomePage(title: \'B\'),'));
      expect(generated, isNot(contains('GoldenStep')));
    });

    test('sequences setupAction/verifyAction after image capture with a TODO', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'desc',
    [
      GoldenStep(
        stepName: 'home',
        widgetBuilder: () => const HomePage(),
        setupAction: (tester) async { await tester.tap(find.text('go')); },
      ),
    ],
    GoldenCaptureConfig(testName: 'x'),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation)!;
      final generated = generateSingleTestsSource(extracted);

      expect(generated, contains('TODO(bc_golden_lint)'));
      final capture = generated.indexOf('await bcWidgetMatchesImage(');
      final setup = generated.indexOf(
        "await ((tester) async {await tester.tap(find.text('go'));})(tester);",
      );
      expect(setup, greaterThan(capture));
    });

    test('generates unique image names for colliding sanitized step names', () {
      const source = '''
void main() {
  BcGoldenCapture.multiple(
    'desc',
    [
      GoldenStep(stepName: 'Home!', widgetBuilder: () => const HomePage()),
      GoldenStep(stepName: 'Home?', widgetBuilder: () => const HomePage()),
    ],
    GoldenCaptureConfig(testName: 'x'),
  );
}
''';
      final invocation = _findMultipleInvocation(source);
      final extracted = extractMultipleCall(invocation)!;
      final generated = generateSingleTestsSource(extracted);

      expect(generated, contains("imageName: 'home',"));
      expect(generated, contains("imageName: 'home_2',"));
    });
  });
}
