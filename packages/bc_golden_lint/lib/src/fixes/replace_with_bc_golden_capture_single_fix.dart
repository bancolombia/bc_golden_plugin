import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Replaces a deprecated `bcGoldenTest(...)` call with
/// `BcGoldenCapture.single(...)`, keeping the rest of the invocation
/// (arguments) untouched — the two functions share an identical parameter
/// list, since `bcGoldenTest` just forwards to `BcGoldenCapture.single`.
class ReplaceWithBcGoldenCaptureSingle extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'bc_golden_lint.replaceWithBcGoldenCaptureSingle',
    DartFixKindPriority.standard,
    "Replace with 'BcGoldenCapture.single'",
  );

  ReplaceWithBcGoldenCaptureSingle({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = node.thisOrAncestorOfType<MethodInvocation>();
    if (invocation == null) return;
    if (invocation.target != null) return;
    if (invocation.methodName.name != 'bcGoldenTest') return;

    final methodName = invocation.methodName;
    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addSimpleReplacement(
        SourceRange(methodName.offset, methodName.length),
        'BcGoldenCapture.single',
      );
    });
  }
}
