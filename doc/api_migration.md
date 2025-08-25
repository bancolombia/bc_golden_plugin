# API Migration Guide: BcGoldenCapture

This guide explains how to migrate from the legacy `bcGoldenTest` function to the new unified `BcGoldenCapture` class.

## Notes

- All existing parameters and functionality remain the same
- `FlowStep` class has been renamed to `GoldenStep` for better clarity
- The new API provides better IntelliSense and documentation
- Logging messages now include `.single` or `.multiple` context for better debugging

The `GoldenFlowConfig` class has been renamed to `GoldenCaptureConfig` and `FlowLayoutType` to `CaptureLayoutType` for better semantic consistency.

The new `BcGoldenCapture` class provides a unified API for both single widget captures and multi-step flow captures, replacing the previous `bcGoldenTest` function with a more consistent and maintainable approach.

## New API Structure

```dart
class BcGoldenCapture {
  // For single widget captures (replaces bcGoldenTest)
  static void single(String description, Future<void> Function(WidgetTester) test, {...});
  
  // For multiple captures/flows (new functionality)  
  static void multiple(String description, List<GoldenStep> steps, GoldenCaptureConfig config, {...});
}
```

## Migration Examples

### Single Widget Tests

**Before (deprecated):**
```dart
bcGoldenTest(
  'My widget test',
  (tester) async {
    // test code
  },
  shouldUseRealShadows: true,
);
```

**After (recommended):**
```dart
BcGoldenCapture.single(
  'My widget test',
  (tester) async {
    // test code
  },
  shouldUseRealShadows: true,
);
```

### Multi-Step Flow Tests

**New functionality:**
```dart
BcGoldenCapture.multiple(
  'My flow test',
  steps,
  config,
  logLevel: Level.debug,
);
```

## 🆕 Benefits of the New API

1. **Unified Interface**: Single entry point for both types of tests
2. **Better Naming**: Clear distinction between `.single` and `.multiple`
3. **Consistent Parameters**: Same parameter structure across both methods
4. **Future Extensibility**: Easy to add new capture types (e.g., `.comparison`, `.interactive`)
5. **Improved Logging**: Better categorization in debug logs

## ⚠️ Deprecation Notice

The legacy function is marked as `@Deprecated` but will continue to work for backward compatibility:

- `bcGoldenTest` → Use `BcGoldenCapture.single`

## 🚀 Migration Timeline

1. **Phase 1**: New API available alongside legacy function
2. **Phase 2**: Legacy function marked as deprecated (current)
3. **Phase 3**: Legacy function will be removed in a future major version

## 📖 Additional Examples

### With Custom Configuration
```dart
BcGoldenCapture.single(
  'Custom config test',
  (tester) async {
    // Configure custom window
    final windowConfig = bcCustomWindowConfigData(
      name: 'Custom Device',
      size: const Size(400, 800),
      pixelDensity: 2.0,
    );
    tester.configureWindow(windowConfig);
    
    // Test widget
    await tester.pumpWidget(MyWidget());
    await expectLater(
      find.byType(MyWidget),
      matchesGoldenFile('goldens/my_widget.png'),
    );
  },
  shouldUseRealShadows: true,
);
```

### Multi-Step Flow with Steps
```dart
BcGoldenCapture.multiple(
  'User journey flow',
  [
    GoldenStep(
      stepName: 'Login Screen',
      widgetBuilder: () => LoginScreen(),
      setupAction: (tester) async {
        // Setup code
      },
    ),
    GoldenStep(
      stepName: 'Dashboard',
      widgetBuilder: () => DashboardScreen(),
      verifyAction: (tester) async {
        // Verification code
      },
    ),
  ],
  const GoldenCaptureConfig(
    layoutType: CaptureLayoutType.vertical,
    spacing: 16,
    testName: 'user_journey',
  ),
);
```

## IDE Support

Most IDEs will show deprecation warnings for the old functions and suggest using the new API. The migration is straightforward - just replace the function name and you're done!

## Class Rename: FlowStep → GoldenStep

The `FlowStep` class has been renamed to `GoldenStep` for better semantic clarity:

```dart
// Before
FlowStep(
  stepName: 'Login Screen', 
  widgetBuilder: () => LoginScreen(),
  setupAction: (tester) async {
    // Setup code
  },
)

// After  
GoldenStep(
  stepName: 'Login Screen',
  widgetBuilder: () => LoginScreen(), 
  setupAction: (tester) async {
    // Setup code
  },
)
```

All functionality remains exactly the same - only the class name has changed.

## Class Rename: GoldenFlowConfig → GoldenCaptureConfig

The `GoldenFlowConfig` class has been renamed to `GoldenCaptureConfig` and `FlowLayoutType` to `CaptureLayoutType` for better semantic consistency:

```dart
// Before
BcGoldenCapture.multiple('test', steps, 
  GoldenFlowConfig(
    testName: 'my_test',
    layoutType: FlowLayoutType.vertical,
    spacing: 16.0,
  )
);

// After  
BcGoldenCapture.multiple('test', steps,
  GoldenCaptureConfig(
    testName: 'my_test', 
    layoutType: CaptureLayoutType.vertical,
    spacing: 16.0,
  )
);
```

All configuration options and functionality remain exactly the same - only the class and enum names have changed.

## Notes

- All existing parameters and functionality remain the same
- `FlowStep` class has been renamed to `GoldenStep` for better clarity
- The new API provides better IntelliSense and documentation
- Logging messages now include `.single` or `.multiple` context for better debugging
