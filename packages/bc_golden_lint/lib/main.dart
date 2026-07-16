import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/assists/convert_multiple_to_single_assist.dart';
import 'src/fixes/replace_with_bc_golden_capture_single_fix.dart';
import 'src/rules/golden_image_name_no_extension.dart';
import 'src/rules/prefer_bc_golden_capture.dart';

final plugin = BcGoldenLintPlugin();

class BcGoldenLintPlugin extends Plugin {
  @override
  String get name => 'bc_golden_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerAssist(ConvertMultipleToSingleAssist.new);

    registry.registerLintRule(GoldenImageNameNoExtension());

    registry.registerLintRule(PreferBcGoldenCapture());
    registry.registerFixForRule(
      PreferBcGoldenCapture.code,
      ReplaceWithBcGoldenCaptureSingle.new,
    );
  }
}
