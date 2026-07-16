import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'convert_multiple_to_single_transform.dart';

/// Offers a quick assist on `BcGoldenCapture.multiple(...)` calls to convert
/// them into separate, independent `BcGoldenCapture.single` tests — one per
/// `GoldenStep`.
///
/// This is a purely mechanical, non-judgmental refactor: it does not try to
/// detect "misuse" of `.multiple` (see the package README for why that
/// heuristic isn't reliable). It only offers an escape hatch for developers
/// who realize they wanted independent golden images instead of one
/// combined image.
class ConvertMultipleToSingleAssist extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addMethodInvocation((node) {
      if (!target.intersects(node.sourceRange)) return;
      if (!isBcGoldenCaptureMultipleInvocation(node)) return;

      final extracted = extractMultipleCall(node);
      if (extracted == null) return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Convert to separate BcGoldenCapture.single tests',
        priority: 1,
      );

      // Replace the enclosing statement (not just the invocation
      // expression) so its trailing `;` is replaced too, instead of being
      // left dangling after the last generated statement.
      final parent = node.parent;
      final replacementRange =
          parent is ExpressionStatement ? parent.sourceRange : node.sourceRange;

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          replacementRange,
          generateSingleTestsSource(extracted).trimRight(),
        );
      });
    });
  }
}
