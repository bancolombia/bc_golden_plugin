import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

/// Dart extension to add an await images function to a [WidgetTester] object,
/// e.g. [awaitImages].
extension AssetLoader on WidgetTester {
  /// Pauses test until images are ready to be rendered.
  /// 
  /// [timeout] The timeout for pumpAndSettle operations. If null, uses the default timeout.
  /// [duration] The duration for pump operations. If null, uses the default duration.
  Future<void> awaitImages({
    Duration? timeout,
    Duration? duration,
  }) async {
    await runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final widget = element.widget as Image;
        final image = widget.image;
        if (image is SvgPicture) {
          await pumpWidget(image as SvgPicture);
          await pumpAndSettle(timeout: timeout, duration: duration);
        } else {
          await precacheImage(image, element);
          await pumpAndSettle(timeout: timeout, duration: duration);
        }
      }

      for (final element in find.byType(DecoratedBox).evaluate()) {
        final widget = element.widget as DecoratedBox;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          final image = decoration.image?.image;
          if (image is SvgPicture) {
            await pumpWidget(image as SvgPicture);
            await pumpAndSettle(timeout: timeout, duration: duration);
          } else if (image != null) {
            await precacheImage(image, element);
            await pumpAndSettle(timeout: timeout, duration: duration);
          }
        }
      }
    });
  }
}

/// Function to load material icons in runtime.
Future<void> loadMaterialIconFont() async {
  const FileSystem fileSystem = LocalFileSystem();
  const Platform platform = LocalPlatform();
  final Directory flutterRoot =
      fileSystem.directory(platform.environment['FLUTTER_ROOT']);

  final File iconFont = flutterRoot.childFile(
    fileSystem.path.join(
      'bin',
      'cache',
      'artifacts',
      'material_fonts',
      'MaterialIcons-Regular.otf',
    ),
  );

  final Future<ByteData> bytes =
      Future<ByteData>.value(iconFont.readAsBytesSync().buffer.asByteData());

  await (FontLoader('MaterialIcons')..addFont(bytes)).load();
}

/// ## loadAppFonts() : Future
/// Function to load fonts in runtime inspired by golden_toolkit.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string),
  );

  for (final Map<String, dynamic> font in fontManifest) {
    final fontLoader = FontLoader(derivedFontFamily(font));
    for (final Map<String, dynamic> fontType in font['fonts']) {
      fontLoader.addFont(rootBundle.load(fontType['asset']));
    }
    await fontLoader.load();
  }
}

@visibleForTesting
String derivedFontFamily(Map<String, dynamic> fontDefinition) {
  if (!fontDefinition.containsKey('family')) {
    return '';
  }

  final String fontFamily = fontDefinition['family'];

  if (_overridableFonts.contains(fontFamily)) {
    return fontFamily;
  }

  if (fontFamily.startsWith('packages/')) {
    final fontFamilyName = fontFamily.split('/').last;
    if (_overridableFonts.any((font) => font == fontFamilyName)) {
      return fontFamilyName;
    }
  } else {
    for (final Map<String, dynamic> fontType in fontDefinition['fonts']) {
      final String? asset = fontType['asset'];
      if (asset != null && asset.startsWith('packages')) {
        final packageName = asset.split('/')[1];

        return 'packages/$packageName/$fontFamily';
      }
    }
  }

  return fontFamily;
}

const List<String> _overridableFonts = [
  'Roboto',
  '.SF UI Display',
  '.SF UI Text',
  '.SF Pro Text',
  '.SF Pro Display',
];
