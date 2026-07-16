import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/convert_multiple_to_single_assist.dart';

/// Entrypoint required by `custom_lint` to load this plugin.
PluginBase createPlugin() => _BcGoldenLintPlugin();

class _BcGoldenLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [];

  @override
  List<Assist> getAssists() => [ConvertMultipleToSingleAssist()];
}
