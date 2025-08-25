# BC Golden Plugin - AI Assistant Instructions

## 🎯 Package Overview
This is a Flutter plugin for automated visual QA testing that enhances native golden tests. It compares UI widgets against design references (Figma) to automate visual quality assurance and reduce time-to-market.

## 🏗️ Architecture & Core Components

### API Design Pattern: Unified BcGoldenCapture Class
The package uses a unified API approach with two main testing modes:
```dart
// Single widget testing (replaces legacy bcGoldenTest)
BcGoldenCapture.single('description', (tester) async { /* test */ });

// Multi-step flow testing (captures multiple screenshots)
BcGoldenCapture.multiple('description', steps, config);
```

### Key Architecture Components
- **`/lib/src/config/`**: Configuration classes for tests and device settings
- **`/lib/src/capture/`**: Screenshot capture and image combination logic
- **`/lib/src/testkit/`**: Core testing tools and utilities
- **`/lib/src/comparators/`**: Custom image comparison with threshold support
- **`/lib/src/helpers/`**: Asset loading, logging, and utility functions

## 🧪 Testing Patterns & Conventions

### File Naming & Structure
- Golden tests MUST end with `_golden_test.dart`
- Tests go in `test/` folder following package structure
- Golden images stored in `test/goldens/` directory

### Configuration Setup (flutter_test_config.dart)
```dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  BcGoldenConfiguration config = BcGoldenConfiguration();
  config.goldenDifferenceThreshold = 30; // CI: 50, Local: 30
  config.willFailOnError = true;
  
  await loadConfiguration();
  await testMain();
}
```

### Multi-Step Flow Testing Pattern
Use `GoldenStep` with `GoldenCaptureConfig` for complex user journeys:
```dart
BcGoldenCapture.multiple('flow_name', [
  GoldenStep(
    stepName: 'screen_name',
    widgetBuilder: () => YourWidget(),
    setupAction: (tester) async { /* optional setup */ },
    verifyAction: (tester) async { /* optional verification */ },
  ),
], GoldenCaptureConfig(
  testName: 'flow_file_name',
  layoutType: CaptureLayoutType.grid, // vertical, horizontal, grid
  maxScreensPerRow: 3,
  spacing: 16.0,
  device: GoldenDeviceData.iPhone13, // Optional device config
));
```

## 🔧 Critical CI/CD Considerations

### Platform Detection
The package auto-detects CI environments (GitHub Actions, GitLab CI, Jenkins) and applies:
- Extended timeouts (10s vs 2s locally) 
- Higher difference thresholds (50% vs 30%)
- Stable rendering configurations

### Device Consistency
ALWAYS use the same device configuration between local and CI:
```dart
// Consistent device across environments
device: GoldenDeviceData.galaxyS25  // Same locally and in CI
```

## ⚡ Key Development Commands

### Testing
```bash
# Run only golden tests
flutter test --tags=golden

# Run with coverage
flutter test --coverage

# Update golden files
flutter test --update-goldens
```

### CI Pipeline Requirements
- Set `CI=true` environment variable
- Use timeout > 5 minutes for multi-screenshot tests
- Ensure consistent device pixel ratios across environments

## 🎨 Theme & Styling Integration

### Theme Configuration
```dart
BcGoldenConfiguration config = BcGoldenConfiguration();
config.setThemeProvider = [/* Provider widgets */];
config.setThemeData = YourThemeData.lightTheme;
```

### Real Shadows Control
```dart
BcGoldenCapture.single('test', (tester) async {
  // test code
}, shouldUseRealShadows: true); // Default: true
```

## 🚨 Common Pitfalls & Solutions

1. **Empty Screenshots in CI**: Package handles with async `toImage()` instead of `toImageSync()`
2. **Inconsistent Device Sizes**: Always specify same device config for local/CI
3. **Timeout Issues**: Package auto-adjusts timeouts based on CI detection
4. **Image Differences**: Use appropriate thresholds (30% local, 50% CI)

## 🔍 Key Files to Reference
- `lib/src/testkit/golden_testing_tools.dart` - Main API implementation
- `lib/src/capture/golden_screenshot.dart` - Screenshot capture logic
- `lib/src/config/golden_capture_config.dart` - Configuration classes
- `example/test/flutter_test_config.dart` - Example configuration
- `example/test/src/presentation/home/home_page_golden_test.dart` - Usage examples

## 📝 Migration Notes
- `bcGoldenTest()` is deprecated → use `BcGoldenCapture.single()`
- `GoldenFlowConfig` renamed → `GoldenCaptureConfig`
- `FlowLayoutType` renamed → `CaptureLayoutType`
- `FlowStep` renamed → `GoldenStep`
