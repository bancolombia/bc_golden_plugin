import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Flags calls to the deprecated `bcGoldenTest` function, in favor of
/// `BcGoldenCapture.single`.
///
/// `bcGoldenTest` is already `@Deprecated`, so the analyzer's built-in
/// `deprecated_member_use` diagnostic already flags it; this rule exists
/// so a companion fix (see `ReplaceWithBcGoldenCaptureSingle`) can offer an
/// automatic migration, which `deprecated_member_use` does not.
class PreferBcGoldenCapture extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_bc_golden_capture',
    "Prefer 'BcGoldenCapture.single' over the deprecated 'bcGoldenTest'.",
    correctionMessage: "Replace 'bcGoldenTest' with 'BcGoldenCapture.single'.",
  );

  PreferBcGoldenCapture()
    : super(
        name: 'prefer_bc_golden_capture',
        description:
            "Reports calls to the deprecated 'bcGoldenTest' function.",
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target != null) return;
    if (node.methodName.name != 'bcGoldenTest') return;

    rule.reportAtNode(node.methodName);
  }
}
