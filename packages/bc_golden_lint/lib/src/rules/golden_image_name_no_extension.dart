import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Flags `bcWidgetMatchesImage(imageName: '...')` calls whose `imageName`
/// includes a `.png` extension.
///
/// `bcWidgetMatchesImage` appends `.png` itself and only `assert`s the
/// absence of the extension at runtime, so this mistake otherwise surfaces
/// late (only when the golden test actually runs), instead of immediately
/// in the IDE.
class GoldenImageNameNoExtension extends AnalysisRule {
  static const LintCode code = LintCode(
    'golden_image_name_no_extension',
    "The 'imageName' argument shouldn't include a file extension.",
    correctionMessage:
        "Remove the '.png' suffix; bcWidgetMatchesImage appends it "
        'automatically.',
  );

  GoldenImageNameNoExtension()
    : super(
        name: 'golden_image_name_no_extension',
        description:
            "Reports when the 'imageName' argument passed to "
            'bcWidgetMatchesImage includes a file extension.',
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
    if (node.methodName.name != 'bcWidgetMatchesImage') return;

    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedArgument) continue;
      if (argument.name.lexeme != 'imageName') continue;

      final value = argument.argumentExpression;
      if (value is SimpleStringLiteral && value.value.endsWith('.png')) {
        rule.reportAtNode(value);
      }
      return;
    }
  }
}
