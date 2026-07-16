import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/assists/convert_multiple_to_single_assist.dart';

final plugin = BcGoldenLintPlugin();

class BcGoldenLintPlugin extends Plugin {
  @override
  String get name => 'bc_golden_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerAssist(ConvertMultipleToSingleAssist.new);
  }
}
