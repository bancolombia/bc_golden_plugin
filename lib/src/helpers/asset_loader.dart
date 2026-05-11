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
  Future<void> awaitImages() async {
    await runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final widget = element.widget as Image;
        final image = widget.image;
        if (image is SvgPicture) {
          await pumpWidget(image as SvgPicture);
          await pumpAndSettle();
        } else {
          await precacheImage(image, element);
          await pumpAndSettle();
        }
      }

      for (final element in find.byType(DecoratedBox).evaluate()) {
        final widget = element.widget as DecoratedBox;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration) {
          final image = decoration.image?.image;
          if (image is SvgPicture) {
            await pumpWidget(image as SvgPicture);
            await pumpAndSettle();
          } else if (image != null) {
            await precacheImage(image, element);
            await pumpAndSettle();
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
///
/// Each font from `FontManifest.json` is registered under every plausible
/// lookup name (see [fontFamilyAliases]) so that an `Icon` widget can find
/// it regardless of whether the underlying `IconData` carries a
/// `fontPackage` or not. This is what allows components that internally map
/// an enum to `IconData(..., fontPackage: '<pkg>')` to render correctly in
/// goldens without callers having to apply [IconExtension.convertToGolden].
///
/// * [currentPackage] When the test runs from inside a Flutter package whose
///   own fonts are listed in the manifest with local paths (i.e. without the
///   `packages/<pkg>/...` prefix), pass the package name here. The font will
///   additionally be registered under `packages/<currentPackage>/<family>`,
///   so an `IconData(..., fontPackage: '<currentPackage>')` defined inside
///   that same package can resolve its glyphs in tests. Has no effect on
///   fonts that already include a `packages/...` prefix or that come from
///   another package.
Future<void> loadAppFonts({String? currentPackage}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (string) async => json.decode(string),
  );

  for (final Map<String, dynamic> font in fontManifest) {
    final List<dynamic>? fonts = font['fonts'] as List<dynamic>?;
    if (fonts == null) continue;

    for (final String alias
        in fontFamilyAliases(font, currentPackage: currentPackage)) {
      final fontLoader = FontLoader(alias);
      for (final Map<String, dynamic> fontType in fonts) {
        final String? asset = fontType['asset'];
        if (asset == null) continue;
        fontLoader.addFont(rootBundle.load(asset));
      }
      await fontLoader.load();
    }
  }
}

/// Returns every font-family alias under which the given font definition
/// from `FontManifest.json` should be registered with `FontLoader`.
///
/// `Icon` looks up its glyphs as either:
/// * `fontFamily`                                  (no `fontPackage`), or
/// * `packages/<fontPackage>/<fontFamily>`         (with `fontPackage`).
///
/// To make icons render in goldens regardless of how the consumer built
/// their `IconData`, we register the font bytes under all variants we can
/// derive from the manifest entry: the raw family name (when it isn't a
/// system font alias), and a `packages/<pkg>/<family>` variant for every
/// distinct package referenced in the asset paths.
///
/// * [currentPackage] When the manifest entry uses a local asset path
///   (no `packages/<pkg>/...` prefix), this value lets the caller declare
///   which package owns the font so that an additional
///   `packages/<currentPackage>/<family>` alias is generated. This covers
///   the case where a package is being tested from inside itself and its
///   own `IconData` definitions reference it via `fontPackage`.
@visibleForTesting
Set<String> fontFamilyAliases(
  Map<String, dynamic> fontDefinition, {
  String? currentPackage,
}) {
  if (!fontDefinition.containsKey('family')) {
    return const <String>{};
  }

  final String fontFamily = fontDefinition['family'];
  final aliases = <String>{};

  // System fonts (Roboto / SF) keep their raw name only.
  if (_overridableFonts.contains(fontFamily)) {
    aliases.add(fontFamily);
    return aliases;
  }

  if (fontFamily.startsWith('packages/')) {
    aliases.add(fontFamily);
    final String trimmed = fontFamily.split('/').last;
    if (!_overridableFonts.contains(trimmed)) {
      aliases.add(trimmed);
    }
    return aliases;
  }

  aliases.add(fontFamily);

  final List<dynamic>? fonts = fontDefinition['fonts'] as List<dynamic>?;
  if (fonts != null) {
    for (final Map<String, dynamic> fontType in fonts) {
      final String? asset = fontType['asset'];
      if (asset != null && asset.startsWith('packages/')) {
        final segments = asset.split('/');
        if (segments.length >= 2) {
          aliases.add('packages/${segments[1]}/$fontFamily');
        }
      }
    }
  }

  // When the font is owned by the package currently under test, also expose
  // it under the `packages/<currentPackage>/<family>` alias so that an
  // `IconData(..., fontPackage: '<currentPackage>')` declared in that same
  // package can resolve its glyphs. This complements the rule above for
  // cases where the manifest lists local asset paths (i.e. tests running
  // from inside the package itself).
  if (currentPackage != null && currentPackage.isNotEmpty) {
    aliases.add('packages/$currentPackage/$fontFamily');
  }

  return aliases;
}

/// Returns the primary registered font-family name for the given manifest
/// entry. Kept for backwards compatibility; new code should prefer
/// [fontFamilyAliases] which returns every alias the font is registered
/// under by [loadAppFonts].
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
