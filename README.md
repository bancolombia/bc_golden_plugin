# ⚜️ bc_golden_plugin ⚜️

## A flutter package for automated visual QA.

This is a package that improves native golden tests and adds features according to needings in our development process, such as automating the visual QA manual process.

Also, it is heavily inspired by other packages like [golden_toolkit](https://pub.dev/packages/golden_toolkit) and [alchemist](https://github.com/Betterment/alchemist).

> An example of the usage can be found in the example directory.

### Contents
* Use cases. 👨🏻‍💻
* Guidelines. 📝
* BcGoldenConfiguration. 🛠
* Window configuration. 📱
* Custom Window Configuration.
* Accessibility. 🦾
* bcGoldenTest. 🏗
* LocalFileComparatorThreshold. 📈
* Example of usage 🤌🏻.


## Use cases 👨🏻‍💻
The main focus of this package is to compare either components or widgets against the designs provided by the Designers Team in Figma. So, to achieve this approach, we've take the native golden test tool and added some features that are going to be explained below.

Let's start with an example of use case, consider the following design:

![Input image](assets/use-cases/insumo.png)

Normally we need to schedule a review with someone of the design team to make a quality assurance, this could increase the time to market while waiting for that meeting. So, in solution to this problematic, we've come to the conclusion that we could use the **Golden Image Testing** but with a different approach.

So now consider the following image as the result of the development process:

![Development image](assets/use-cases/golden_image.png)

As you can see there are actually visual differences.

## Guidelines 📝
* The tests folder should be inside the package *test folder*.
* The test should be named with *_golden_test.dart* notation.

## BcGoldenConfiguration. 🛠
The BcGoldenConfiguration handles the theme provider and theme data used by the application, so in here you can set your themes to run the tests. You could set this configuration in the **flutter_test_config.dart** like the following: 

```dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

  bcGoldenConfiguration.setThemeProvider = [
    ChangeNotifierProvider(create: (_) => BcThemeNotifier()),
    ...BancolombiaFoundations.themeProvider,
  ];

  bcGoldenConfiguration.setThemeData = BcThemeData.lightTheme;

  await loadConfiguration();

  await testMain();
}
```
Or you can also do it by each tests case if you want.

## Window Configuration | Devices 📱
The following are the windows configurations that are available in the package to simulate a physical device:

| name  | viewport size | pixel ratio |
| ----- | ---- | ------------  |
| `iPhone 8` | 375 x 667 | 2.0
| `iPhone 13` | 390 x 844 | 3.0
| `iPhone 14 Pro max` | 430 x 932 | 3.0
| `Pixel 5` | 360 x 764 | 3.0
| `iPad Pro` | 1366 x 1024 | 2.0

Here are some examples of how are goldens rendered:
| device  | example | 
| ----- | ---- | 
| `iPhone 8` | ![iPhone8 image](assets/use-cases/home_page_iphone_8.png)| 
| `iPad Pro` | ![iPad Pro image](assets/use-cases/home_page_ipad_pro.png)| 


## Custom Window Configuration 
You can also use a custom window configuration if none of the above are useful for you, here is an example: 

```dart
bcGoldenTest(
    'Test con custom window config data',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'golden',
        widget: const HomePage(title: "Flutter Demo Home Page"),
        tester: tester,
        device: bcCustomWindowConfigData(
          name: 'Custom Configuraton',
          pixelDensity: 3.0,
          size: const Size(375, 828),
        ),
      );
    },
  );

```


## Accessibility. 🦾
For testing accesibility there is a `textScaleFactor`parameter that will increase the font size depending in the given number, for example:

| iPhone8 normal  | iPhone8 with text scale factor | 
| ----- | ---- | 
| ![iPhone8 image](assets/use-cases/home_page_iphone_8.png) | ![iPhone8 text scale](assets/use-cases/home_page_iphone_text_scale_factor.png)|



## bcGoldenTest 🏗
The is a personalized function that is default tagged with "golden" and also has aditional features for the tests, see the code below:

```dart
/// ## bcGoldenTest
/// Function to call the golden test, it replaces the testWigets. This functions
/// are tagged with 'golden'.
///
/// * [description] A brief description of the test,
/// * [test] The test itself,
/// * [shouldUseRealShadows] Whether to render shadows or not,
@isTest
void bcGoldenTest(
  String description,
  Future<void> Function(WidgetTester) test, {
  bool shouldUseRealShadows = false,
}) {
  testWidgets(
    description,
    (widgetTester) async {
      body() async {
        final initialDebugDisableShadowsValue = debugDisableShadows;
        debugDisableShadows = !shouldUseRealShadows;
        try {
          await test(widgetTester);
        } finally {
          debugDisableShadows = initialDebugDisableShadowsValue;
          debugDefaultTargetPlatformOverride = null;
        }
      }

      await body();
    },
    tags: ['golden'],
  );
}

```
As you can see you can also change the shadows as well the platform to run test in. Here is an example of the usage;

```dart
bcGoldenTest(
    '<name of the test file>',
    (tester) async {
      // Test goes here
    },
    shouldUseRealShadows: true,
  );

```

## LocalFileComparator
The local file comparator class will let customize the aceptable difference between two images,
so if the difference is below this custom value the test will pass.

```dart
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  final double threshold;

  LocalFileComparatorWithThreshold(Uri testFile, this.threshold)
      : assert(threshold >= 0 && threshold <= 1),
        super(testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      debugPrint(
        'Se encontró una diferencia de ${result.diffPercent * 100}%, pero es '
        'un valor aceptable, dado que el porcentaje de aceptación es de '
        '${threshold * 100}%',
      );

      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

```

## Example of usage 🤌🏻
Using the package it's pretty simple as it's shown in the test below:

```dart
bcGoldenTest(
    'button_widget_golden',
    (tester) async {
      await bcWidgetMatchesImage(
        imageName: 'button_widget',
        widget: ButtonWidget(),
        tester: tester,
        device: iPhone8,
        textScaleFactor: 2.0,
      );
    },
    shouldUseRealShadows: true,
  );
```
This will generate the golden and will make the comparison between the given image and the widget developed.