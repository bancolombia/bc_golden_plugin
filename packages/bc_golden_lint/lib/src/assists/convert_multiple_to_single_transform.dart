import 'package:analyzer/dart/ast/ast.dart';

import '../utils/name_sanitizer.dart';

/// One step extracted from a `BcGoldenCapture.multiple(...)` call.
class ExtractedGoldenStep {
  ExtractedGoldenStep({
    required this.stepNameLiteral,
    required this.stepNameSource,
    required this.widgetSource,
    this.setupActionSource,
    this.verifyActionSource,
  });

  /// The literal string value of `stepName`, or `null` if it wasn't a
  /// simple string literal (e.g. an interpolated/const expression).
  final String? stepNameLiteral;

  /// The raw source of the `stepName` expression, always safe to embed
  /// inside a string interpolation.
  final String stepNameSource;

  /// The source of the widget expression built by `widgetBuilder`.
  final String widgetSource;

  /// The raw source of `setupAction`, if present.
  final String? setupActionSource;

  /// The raw source of `verifyAction`, if present.
  final String? verifyActionSource;
}

/// A fully-parsed `BcGoldenCapture.multiple(...)` invocation.
class ExtractedMultipleCall {
  ExtractedMultipleCall({
    required this.descriptionSource,
    required this.steps,
    this.deviceSource,
    this.logLevelSource,
    this.shouldUseRealShadowsSource,
  });

  final String descriptionSource;
  final List<ExtractedGoldenStep> steps;
  final String? deviceSource;
  final String? logLevelSource;
  final String? shouldUseRealShadowsSource;
}

/// Returns `true` if [node] looks like a `BcGoldenCapture.multiple(...)`
/// call. This check is purely syntactic (no type resolution), so it could
/// in principle match an unrelated `BcGoldenCapture` class; that trade-off
/// is intentional to keep the assist fast and dependency-free.
bool isBcGoldenCaptureMultipleInvocation(MethodInvocation node) {
  if (node.methodName.name != 'multiple') return false;
  final target = node.target;
  if (target == null) return false;
  return RegExp(r'(^|\.)BcGoldenCapture$').hasMatch(target.toSource());
}

/// Attempts to extract everything needed to rewrite [node] into separate
/// `BcGoldenCapture.single` calls.
///
/// Returns `null` when the call doesn't have a shape that can be safely
/// rewritten mechanically (e.g. the steps list isn't a literal list of
/// `GoldenStep(...)`, contains a spread, or is a variable reference) —
/// callers must not offer the assist in that case rather than attempt a
/// partial rewrite.
ExtractedMultipleCall? extractMultipleCall(MethodInvocation node) {
  final positional = node.argumentList.arguments
      .where((argument) => argument is! NamedArgument)
      .toList();
  if (positional.length < 3) return null;

  final stepsArg = positional[1];
  if (stepsArg is! ListLiteral) return null;

  final steps = <ExtractedGoldenStep>[];
  for (final element in stepsArg.elements) {
    if (element is! Expression) return null;
    final stepArgs = _constructorLikeArguments(element, 'GoldenStep');
    if (stepArgs == null) return null;

    final step = _extractStep(stepArgs);
    if (step == null) return null;
    steps.add(step);
  }
  if (steps.isEmpty) return null;

  final configArgs =
      _constructorLikeArguments(positional[2], 'GoldenCaptureConfig');
  final deviceSource =
      configArgs == null ? null : _namedArgSource(configArgs, 'device');

  String? logLevelSource;
  String? shouldUseRealShadowsSource;
  for (final named
      in node.argumentList.arguments.whereType<NamedArgument>()) {
    switch (named.name.lexeme) {
      case 'logLevel':
        logLevelSource = named.argumentExpression.toSource();
      case 'shouldUseRealShadows':
        shouldUseRealShadowsSource = named.argumentExpression.toSource();
    }
  }

  return ExtractedMultipleCall(
    descriptionSource: positional[0].toSource(),
    steps: steps,
    deviceSource: deviceSource,
    logLevelSource: logLevelSource,
    shouldUseRealShadowsSource: shouldUseRealShadowsSource,
  );
}

/// Generates the Dart source that should replace the original
/// `BcGoldenCapture.multiple(...)` invocation.
String generateSingleTestsSource(ExtractedMultipleCall call) {
  final imageNames = sanitizeStepNamesUniquely([
    for (var i = 0; i < call.steps.length; i++)
      call.steps[i].stepNameLiteral ?? 'step_${i + 1}',
  ]);

  final buffer = StringBuffer();
  for (var i = 0; i < call.steps.length; i++) {
    final step = call.steps[i];
    final imageName = imageNames[i];

    buffer.writeln('BcGoldenCapture.single(');
    buffer.writeln(
      "  '\${${call.descriptionSource}} - \${${step.stepNameSource}}',",
    );
    buffer.writeln('  (tester) async {');
    if (step.setupActionSource != null || step.verifyActionSource != null) {
      buffer.writeln(
        '    // TODO(bc_golden_lint): review setup/verify ordering — '
        'this mechanical conversion runs them after image capture, not '
        'interleaved with pump/settle as BcGoldenCapture.multiple did.',
      );
    }
    buffer.writeln('    await bcWidgetMatchesImage(');
    buffer.writeln("      imageName: '$imageName',");
    buffer.writeln('      widget: ${step.widgetSource},');
    buffer.writeln('      tester: tester,');
    if (call.deviceSource != null) {
      buffer.writeln('      device: ${call.deviceSource},');
    }
    buffer.writeln('    );');
    if (step.setupActionSource != null) {
      buffer.writeln('    await (${step.setupActionSource})(tester);');
    }
    if (step.verifyActionSource != null) {
      buffer.writeln('    await (${step.verifyActionSource})(tester);');
    }
    buffer.writeln('  },');
    if (call.logLevelSource != null) {
      buffer.writeln('  logLevel: ${call.logLevelSource},');
    }
    if (call.shouldUseRealShadowsSource != null) {
      buffer.writeln(
        '  shouldUseRealShadows: ${call.shouldUseRealShadowsSource},',
      );
    }
    buffer.writeln(');');
    if (i != call.steps.length - 1) buffer.writeln();
  }

  return buffer.toString();
}

/// Returns the [ArgumentList] of [expr] if it is a call to a constructor
/// named [name] — either an [InstanceCreationExpression] (when the unit is
/// fully resolved, e.g. `GoldenStep(...)`/`const GoldenStep(...)`) or a
/// bare [MethodInvocation] (the shape an *unresolved* parse gives an
/// unprefixed call like `GoldenStep(...)` before the analyzer can bind it
/// to a constructor). Returns `null` otherwise.
ArgumentList? _constructorLikeArguments(Argument expr, String name) {
  if (expr is InstanceCreationExpression) {
    return expr.constructorName.type.name.lexeme == name
        ? expr.argumentList
        : null;
  }
  if (expr is MethodInvocation) {
    return expr.target == null && expr.methodName.name == name
        ? expr.argumentList
        : null;
  }
  return null;
}

ExtractedGoldenStep? _extractStep(ArgumentList args) {
  final stepNameExpr = _namedArgExpression(args, 'stepName');
  final widgetBuilderExpr = _namedArgExpression(args, 'widgetBuilder');
  if (stepNameExpr == null || widgetBuilderExpr == null) return null;
  if (widgetBuilderExpr is! FunctionExpression) return null;

  final widgetSource = _widgetExpressionSource(widgetBuilderExpr);
  if (widgetSource == null) return null;

  return ExtractedGoldenStep(
    stepNameLiteral:
        stepNameExpr is SimpleStringLiteral ? stepNameExpr.value : null,
    stepNameSource: stepNameExpr.toSource(),
    widgetSource: widgetSource,
    setupActionSource: _namedArgSource(args, 'setupAction'),
    verifyActionSource: _namedArgSource(args, 'verifyAction'),
  );
}

String? _widgetExpressionSource(FunctionExpression function) {
  final body = function.body;
  if (body is ExpressionFunctionBody) {
    return body.expression.toSource();
  }
  if (body is BlockFunctionBody) {
    final statements = body.block.statements;
    if (statements.length == 1 && statements.first is ReturnStatement) {
      final returnExpr = (statements.first as ReturnStatement).expression;
      if (returnExpr != null) return returnExpr.toSource();
    }
    // Multi-statement builder: keep it intact as an IIFE instead of
    // attempting to inline/rewrite its semantics.
    return '(${function.toSource()})()';
  }
  return null;
}

Expression? _namedArgExpression(ArgumentList args, String name) {
  for (final argument in args.arguments) {
    if (argument is NamedArgument && argument.name.lexeme == name) {
      return argument.argumentExpression;
    }
  }
  return null;
}

String? _namedArgSource(ArgumentList args, String name) {
  return _namedArgExpression(args, name)?.toSource();
}
