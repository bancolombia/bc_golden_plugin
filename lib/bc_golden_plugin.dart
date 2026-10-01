/// A library for the bc_golden_plugin.
///
/// This library provides configuration and testing tools for the bc_golden_plugin.
library;

export 'src/capture/golden_animation_capture.dart';
export 'src/capture/golden_screenshot.dart';
export 'src/comparators/local_file_comparator_with_threshold.dart'
    show LocalFileComparatorWithThreshold, localFileComparator;
export 'src/config/bc_golden_configuration.dart';
export 'src/config/golden_animation_config.dart';
export 'src/config/golden_capture_config.dart';
export 'src/config/golden_device_data.dart';
export 'src/config/window_configuration.dart';
export 'src/helpers/logger.dart' show Level;
export 'src/testkit/golden_testing_tools.dart';
export 'src/testkit/test_base.dart';
export 'src/testkit/window_size.dart' show WindowConfig, WindowConfigData;
