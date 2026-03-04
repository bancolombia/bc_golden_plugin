---
name: bc-golden-testing
description: Expert guidance for creating visual regression tests using bc_golden_plugin for Flutter applications
keywords: golden, testing, visual, regression, flutter, ui, screenshot, widget, test
version: 1.0.0
metadata: 
  author: juan-campuzano
---

# BC Golden Testing Skill

This skill provides comprehensive guidance for creating visual regression tests (golden tests) using the `bc_golden_plugin` Flutter package. Golden tests compare widget screenshots against reference images to catch visual regressions.

## Core Concepts

Golden testing with bc_golden_plugin enables:
- Automated visual QA to replace manual design reviews
- Comparison of implemented widgets against Figma designs
- Multi-device testing with predefined device configurations
- Accessibility testing with text scale factors
- Multi-step flow testing for complete user journeys
- Animation frame testing at specific timestamps

## Package Setup

### 1. Add Dependency

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  bc_golden_plugin: ^2.0.0
```

### 2. Configure Test Environment

Create `test/flutter_test_config.dart`:
```dart
import 'dart:async';
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();
  
  // Optional: Set acceptable difference threshold (0-100%)
  bcGoldenConfiguration.goldenDifferenceThreshold = 30;
  
  // Optional: Configure theme providers if needed
  // bcGoldenConfiguration.setThemeProvider = [
  //   ChangeNotifierProvider(create: (_) => YourThemeNotifier()),
  // ];
  
  // Optional: Set theme data
  // bcGoldenConfiguration.setThemeData = YourThemeData.lightTheme;
  
  await loadConfiguration();
  await testMain();
}
```

### 3. Test File Naming Convention

Golden test files MUST follow this pattern:
- Location: `test/` directory (or subdirectories)
- Naming: `*_golden_test.dart`
- Example: `button_widget_golden_test.dart`

## API Overview

The package provides three main testing approaches:

1. **BcGoldenCapture.single** - For individual widget tests (RECOMMENDED)
2. **BcGoldenCapture.multiple** - For testing variations in a screen or component
3. **BcGoldenCapture.animation** - For animation frame testing
4. **bcGoldenTest** - Legacy API (DEPRECATED, use BcGoldenCapture.single instead)

## Single Widget Testing

Use `BcGoldenCapture.single` for testing individual widgets or screens.

### Basic Example

```dart
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BcGoldenCapture.single(
    'Button widget renders correctly',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'button_widget',
        widget: MyButton(),
        tester: tester,
        device: GoldenDeviceData.iPhone13,
      );
    },
  );
}
```

### With Device Configuration

```dart
BcGoldenCapture.single(
  'Login screen on iPhone 14 Pro Max',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'login_iphone_14_pro',
      widget: LoginScreen(),
      tester: tester,
      device: GoldenDeviceData.iPhone16ProMax,
    );
  },
);
```

### With Accessibility Testing

```dart
BcGoldenCapture.single(
  'Button with large text scale',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'button_large_text',
      widget: MyButton(),
      tester: tester,
      device: GoldenDeviceData.iPhone13,
      textScaleFactor: 2.0, // Simulates accessibility text scaling
    );
  },
);
```

### With Real Shadows

```dart
BcGoldenCapture.single(
  'Card with shadows',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'card_with_shadows',
      widget: MyCard(),
      tester: tester,
      device: GoldenDeviceData.pixel5,
    );
  },
  shouldUseRealShadows: true, // Enable shadow rendering
);
```

## Available Devices

Pre-configured device profiles:

| Device | Viewport Size | Pixel Ratio |
|--------|--------------|-------------|
| `GoldenDeviceData.iPhone8` | 375 x 667 | 2.0 |
| `GoldenDeviceData.iPhone13` | 390 x 844 | 3.0 |
| `GoldenDeviceData.iPhone16ProMax` | 430 x 932 | 3.0 |
| `GoldenDeviceData.pixel5` | 360 x 764 | 3.0 |
| `GoldenDeviceData.iPadPro` | 1366 x 1024 | 2.0 |
| `GoldenDeviceData.galaxyS25` | Custom | 3.0 |

### Custom Device Configuration

```dart
BcGoldenCapture.single(
  'Custom device test',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'custom_device',
      widget: MyWidget(),
      tester: tester,
      device: bcCustomWindowConfigData(
        name: 'Custom Phone',
        pixelDensity: 3.0,
        size: const Size(375, 828),
      ),
    );
  },
);
```

## Multi-Step Flow Testing

Use `BcGoldenCapture.multiple` to test complete user journeys by capturing multiple screens and combining them into a single golden file.

### Basic Flow Example

```dart
BcGoldenCapture.multiple(
  'User onboarding flow',
  [
    GoldenStep(
      stepName: 'Welcome Screen',
      widgetBuilder: () => WelcomeScreen(),
    ),
    GoldenStep(
      stepName: 'Features Screen',
      widgetBuilder: () => FeaturesScreen(),
    ),
    GoldenStep(
      stepName: 'Permissions Screen',
      widgetBuilder: () => PermissionsScreen(),
    ),
  ],
  const GoldenCaptureConfig(
    testName: 'onboarding_flow',
    layoutType: CaptureLayoutType.vertical,
    spacing: 16.0,
  ),
);
```

### With Setup and Verification Actions

```dart
BcGoldenCapture.multiple(
  'Login flow with interactions',
  [
    GoldenStep(
      stepName: 'Login Form',
      widgetBuilder: () => LoginScreen(),
      setupAction: (tester) async {
        // Actions before screenshot
        await tester.enterText(find.byKey(Key('email')), 'user@example.com');
        await tester.pump();
      },
    ),
    GoldenStep(
      stepName: 'Dashboard',
      widgetBuilder: () => DashboardScreen(),
      verifyAction: (tester) async {
        // Verification after screenshot
        expect(find.text('Welcome'), findsOneWidget);
      },
    ),
  ],
  const GoldenCaptureConfig(
    testName: 'login_flow',
    layoutType: CaptureLayoutType.horizontal,
    spacing: 24.0,
  ),
);
```

### Layout Types

Configure how screenshots are arranged:

```dart
// Vertical stacking
GoldenCaptureConfig(
  testName: 'vertical_flow',
  layoutType: CaptureLayoutType.vertical,
  spacing: 16.0,
)

// Horizontal arrangement
GoldenCaptureConfig(
  testName: 'horizontal_flow',
  layoutType: CaptureLayoutType.horizontal,
  spacing: 20.0,
)

// Grid layout
GoldenCaptureConfig(
  testName: 'grid_flow',
  layoutType: CaptureLayoutType.grid,
  maxScreensPerRow: 2,
  spacing: 24.0,
)
```

### With Device Configuration

```dart
BcGoldenCapture.multiple(
  'Checkout flow on iPhone',
  [
    GoldenStep(
      stepName: 'Cart',
      widgetBuilder: () => CartScreen(),
    ),
    GoldenStep(
      stepName: 'Payment',
      widgetBuilder: () => PaymentScreen(),
    ),
  ],
  GoldenCaptureConfig(
    testName: 'checkout_flow',
    device: GoldenDeviceData.iPhone13,
    layoutType: CaptureLayoutType.horizontal,
    spacing: 100,
  ),
);
```

## Animation Testing

Use `BcGoldenCapture.animation` to capture animation frames at specific timestamps.

### Basic Animation Test

```dart
BcGoldenCapture.animation(
  'Button scale animation',
  () => AnimatedButton(),
  const GoldenAnimationConfig(
    testName: 'button_animation',
    totalDuration: Duration(milliseconds: 300),
    animationSteps: [
      GoldenAnimationStep(
        timestamp: Duration.zero,
        frameName: 'start',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 150),
        frameName: 'scaled',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 300),
        frameName: 'end',
      ),
    ],
    layoutType: CaptureLayoutType.horizontal,
    showTimelineLabels: true,
  ),
);
```

### Loading Spinner Animation

```dart
BcGoldenCapture.animation(
  'Loading spinner rotation',
  () => const CircularProgressIndicator(),
  const GoldenAnimationConfig(
    testName: 'spinner_rotation',
    totalDuration: Duration(milliseconds: 1000),
    animationSteps: [
      GoldenAnimationStep(
        timestamp: Duration.zero,
        frameName: '0_degrees',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 250),
        frameName: '90_degrees',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 500),
        frameName: '180_degrees',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 750),
        frameName: '270_degrees',
      ),
    ],
    layoutType: CaptureLayoutType.grid,
    maxScreensPerRow: 2,
    showTimelineLabels: true,
  ),
);
```

### With Animation Setup

```dart
BcGoldenCapture.animation(
  'Fade transition',
  () => FadeTransitionWidget(),
  GoldenAnimationConfig(
    testName: 'fade_transition',
    totalDuration: Duration(milliseconds: 500),
    animationSteps: [
      GoldenAnimationStep(
        timestamp: Duration.zero,
        frameName: 'invisible',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 250),
        frameName: 'half_visible',
      ),
      GoldenAnimationStep(
        timestamp: Duration(milliseconds: 500),
        frameName: 'fully_visible',
      ),
    ],
    layoutType: CaptureLayoutType.horizontal,
    spacing: 20.0,
    device: GoldenDeviceData.iPhone13,
  ),
  animationSetup: (tester) async {
    // Trigger the animation
    await tester.tap(find.byType(FadeTransitionWidget));
    await tester.pump();
  },
);
```

## Advanced: Manual Screenshot Control

For complex scenarios requiring manual control over screenshot timing:

```dart
BcGoldenCapture.single('Manual golden test', (tester) async {
  await tester.runAsync(() async {
    // Configure device
    tester.configureWindow(GoldenDeviceData.iPhone13);

    // Pump initial widget
    await tester.pumpWidget(
      TestBase.appGoldenTest(
        widget: const HomePage(title: 'Home'),
        key: GlobalKey(),
      ),
    );
    await tester.pumpAndSettle();

    // Capture first screenshot
    await tester.captureGoldenScreenshot();

    // Perform interaction
    await tester.tap(find.byKey(const Key('next_button')));
    await tester.pumpAndSettle();

    // Capture second screenshot
    await tester.captureGoldenScreenshot();

    // Combine screenshots
    final combinedScreenshot = await tester.combineGoldenScreenshots(
      GoldenCaptureConfig(
        testName: 'manual_flow',
        device: GoldenDeviceData.iPhone13,
        layoutType: CaptureLayoutType.horizontal,
      ),
      ['home', 'next_page'],
    );

    // Assert against golden file
    await expectLater(
      combinedScreenshot,
      matchesGoldenFile('goldens/manual_flow.png'),
    );
  });
});
```

## Running Golden Tests

### Generate/Update Golden Files

```bash
# Generate golden files for all tests, in case there are no goldens generated
flutter test --update-goldens --tags=golden

# Generate for specific test file
flutter test test/widgets/button_golden_test.dart --update-goldens

# Generate for specific test
flutter test test/widgets/button_golden_test.dart --update-goldens --name="Button widget renders correctly"
```

### Run Golden Tests

```bash
# Run all golden tests
flutter test --tags=golden

# Run specific golden test file
flutter test test/widgets/button_golden_test.dart

# Run with coverage
flutter test --coverage --tags=golden
```

## Best Practices

### 1. Test Organization

```
test/
├── flutter_test_config.dart
├── widgets/
│   ├── button_golden_test.dart
│   ├── card_golden_test.dart
│   └── goldens/
│       ├── button_widget.png
│       └── card_widget.png
├── screens/
│   ├── login_golden_test.dart
│   └── goldens/
│       └── login_screen.png
└── flows/
    ├── onboarding_golden_test.dart
    └── goldens/
        └── onboarding_flow.png
```

### 2. Naming Conventions

- Test files: `*_golden_test.dart`
- Image names: Use descriptive snake_case names
- Test descriptions: Clear, specific descriptions

### 3. Device Selection

- Use iPhone13 or pixel5 for standard mobile testing
- Use iPadPro for tablet testing
- Test critical widgets on multiple devices
- Use custom configurations for specific requirements

### 4. Accessibility Testing

Always test with text scale factors:
```dart
// Test with normal text
await bcWidgetMatchesImage(
  imageName: 'widget_normal',
  widget: MyWidget(),
  tester: tester,
);

// Test with large text (accessibility)
await bcWidgetMatchesImage(
  imageName: 'widget_large_text',
  widget: MyWidget(),
  tester: tester,
  textScaleFactor: 2.0,
);
```

### 5. Threshold Configuration

Set acceptable difference thresholds in `flutter_test_config.dart`:
```dart
bcGoldenConfiguration.goldenDifferenceThreshold = 30; // 30% tolerance
```

Use this for:
- Anti-aliasing differences across platforms
- Minor rendering variations
- Font rendering differences

### 6. Multi-Step Flow Testing

Use for:
- Onboarding flows
- Checkout processes
- Multi-screen wizards
- Navigation flows

Benefits:
- Single golden file for entire flow
- Easier to review complete journeys
- Catches navigation issues

### 7. Animation Testing

Use for:
- Loading indicators
- Transitions
- Interactive animations
- State changes

Capture key frames:
- Start state
- Mid-animation
- End state
- Critical transition points

## Common Patterns

### Testing Different States

```dart
void main() {
  BcGoldenCapture.single(
    'Button states',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'button_enabled',
        widget: MyButton(enabled: true),
        tester: tester,
      );
    },
  );

  BcGoldenCapture.single(
    'Button disabled state',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'button_disabled',
        widget: MyButton(enabled: false),
        tester: tester,
      );
    },
  );
}
```

### Testing with Different Themes

```dart
BcGoldenCapture.single(
  'Widget in dark theme',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'widget_dark',
      widget: Theme(
        data: ThemeData.dark(),
        child: MyWidget(),
      ),
      tester: tester,
    );
  },
);
```

### Testing Responsive Layouts

```dart
void main() {
  for (final device in [
    GoldenDeviceData.iPhone13,
    GoldenDeviceData.iPadPro,
  ]) {
    BcGoldenCapture.single(
      'Responsive layout on ${device.name}',
      (tester) async {
        await bcWidgetMatchesImage(
          imageName: 'responsive_${device.name}',
          widget: ResponsiveWidget(),
          tester: tester,
          device: device,
        );
      },
    );
  }
}
```

## Troubleshooting

### Golden Files Not Matching

1. Check platform differences (run tests on same OS)
2. Adjust threshold in configuration
3. Regenerate golden files: `flutter test --update-goldens`

### Shadows Not Rendering

Use `shouldUseRealShadows: true` in BcGoldenCapture.single

### Text Rendering Differences

- Ensure fonts are included in pubspec.yaml
- Use consistent font families
- Consider platform-specific rendering

### Animation Tests Failing

- Verify totalDuration matches animation duration
- Check timestamp values are within duration
- Ensure animation starts automatically or use animationSetup

## Migration from Legacy API

If you have existing tests using `bcGoldenTest`, migrate to `BcGoldenCapture.single`:

### Before (Deprecated)
```dart
bcGoldenTest(
  'My test',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'my_widget',
      widget: MyWidget(),
      tester: tester,
    );
  },
  shouldUseRealShadows: true,
);
```

### After (Recommended)
```dart
BcGoldenCapture.single(
  'My test',
  (tester) async {
    await bcWidgetMatchesImage(
      imageName: 'my_widget',
      widget: MyWidget(),
      tester: tester,
    );
  },
  shouldUseRealShadows: true,
);
```

The API is identical, just replace `bcGoldenTest` with `BcGoldenCapture.single`.

## Summary

When creating golden tests with bc_golden_plugin:

1. Use `BcGoldenCapture.single` for individual widgets
2. Use `BcGoldenCapture.multiple` for testing variations in a screen or component
3. Use `BcGoldenCapture.animation` for animation testing
4. Follow naming conventions: `*_golden_test.dart`
5. Configure test environment in `flutter_test_config.dart`
6. Test on multiple devices when needed
7. Include accessibility testing with text scale factors
8. Use appropriate thresholds for platform differences
9. Organize golden files in `goldens/` subdirectories
10. Run `flutter test --update-goldens` to generate/update reference images

