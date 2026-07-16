import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

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
class ConvertMultipleToSingleAssist extends ResolvedCorrectionProducer {
  static const _kind = AssistKind(
    'bc_golden_lint.convertMultipleToSingle',
    30,
    'Convert to separate BcGoldenCapture.single tests',
  );

  ConvertMultipleToSingleAssist({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = _findEnclosingMultipleInvocation(node);
    if (invocation == null) return;

    final extracted = extractMultipleCall(invocation);
    if (extracted == null) return;

    // Replace the enclosing statement (not just the invocation expression)
    // so its trailing `;` is replaced too, instead of being left dangling
    // after the last generated statement.
    final parent = invocation.parent;
    final replacementRange =
        parent is ExpressionStatement ? parent : invocation;

    final range = SourceRange(
      replacementRange.offset,
      replacementRange.length,
    );

    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addReplacement(range, (edit) {
        edit.write(generateSingleTestsSource(extracted).trimRight());
      });
    });
  }

  /// Walks up from [start] looking for the nearest enclosing
  /// `BcGoldenCapture.multiple(...)` invocation, so the assist is offered
  /// no matter where the cursor sits inside the call (including nested
  /// inside one of the `GoldenStep`s).
  MethodInvocation? _findEnclosingMultipleInvocation(AstNode start) {
    AstNode? current = start;
    while (current != null) {
      if (current is MethodInvocation &&
          isBcGoldenCaptureMultipleInvocation(current)) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
