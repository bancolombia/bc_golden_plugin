import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../config/bc_golden_configuration.dart';

class TestBase {
  /// Builds the widget tree used to render a golden test.
  ///
  /// * [widget] The widget under test.
  /// * [customTheme] Overrides the theme configured in [BcGoldenConfiguration]
  ///   for a single test.
  /// * [localizationsDelegates] / [supportedLocales] / [locale] Configure
  ///   internationalization so widgets that read localized strings render
  ///   correctly in the golden. When omitted, the previous behavior is kept.
  /// * [appWrapper] Optional builder to wrap the whole app under test with an
  ///   external dependency tree (e.g. a Riverpod `ProviderScope`, a Bloc
  ///   provider, a GetIt scope). It receives the configured [MaterialApp] and
  ///   must return a widget that contains it. When omitted, the app is used
  ///   as-is, preserving the previous behavior.
  /// * [wrapInScaffold] When `true` (default) the [widget] is placed inside a
  ///   plain [Scaffold]; set it to `false` when the [widget] already provides
  ///   its own scaffold (e.g. a full screen), so the golden reflects the real
  ///   screen instead of a double scaffold.
  /// * [includeOverlays] When `true`, theme providers and the screenshot
  ///   [RepaintBoundary] wrap the Navigator via [MaterialApp.builder], so
  ///   overlays such as dialogs are included in golden captures and can read
  ///   the configured providers. Defaults to `false` to preserve existing
  ///   golden images; enable it only on tests that need dialog/overlay coverage.
  static Widget appGoldenTest({
    required Widget widget,
    GlobalKey? key,
    double? height,
    double? width,
    double? textScaleFactor,
    ThemeData? customTheme,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    Iterable<Locale>? supportedLocales,
    Locale? locale,
    Widget Function(Widget app)? appWrapper,
    bool wrapInScaffold = true,
    bool includeOverlays = false,
  }) {
    BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

    final List<SingleChildWidget>? themeProviders =
        bcGoldenConfiguration.themeProvider;
    final bool hasThemeProvider = themeProviders != null;

    final Widget homeChild = _AppWidgetBaseTest(
      widget: widget,
      height: includeOverlays ? null : height,
      width: includeOverlays ? null : width,
      textScaleFactor: includeOverlays ? null : textScaleFactor,
      wrapInScaffold: wrapInScaffold,
      wrapForCapture: !includeOverlays,
    );

    Widget appWidget = MaterialApp(
      key: key,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales ?? const <Locale>[Locale('en')],
      locale: locale,
      theme: customTheme ?? bcGoldenConfiguration.themeData,
      builder: includeOverlays
          ? (BuildContext context, Widget? child) {
              return _wrapNavigatorForOverlays(
                context: context,
                child: child,
                height: height,
                width: width,
                textScaleFactor: textScaleFactor,
                themeProviders:
                    hasThemeProvider && themeProviders.isNotEmpty
                        ? themeProviders
                        : null,
              );
            }
          : null,
      home: includeOverlays
          ? homeChild
          : hasThemeProvider
              ? MultiProvider(
                  providers: themeProviders,
                  child: homeChild,
                )
              : homeChild,
    );

    if (appWrapper != null) {
      appWidget = appWrapper(appWidget);
    }

    return appWidget;
  }

  /// Wraps the Navigator so overlays share providers and the capture boundary.
  static Widget _wrapNavigatorForOverlays({
    required BuildContext context,
    required Widget? child,
    required double? height,
    required double? width,
    required double? textScaleFactor,
    required List<SingleChildWidget>? themeProviders,
  }) {
    Widget navigatorChild = child ?? const SizedBox.shrink();

    if (textScaleFactor != null) {
      navigatorChild = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: navigatorChild,
      );
    }

    Widget content = RepaintBoundary(
      child: SizedBox(
        height: height,
        width: width,
        child: navigatorChild,
      ),
    );

    if (height != null || width != null) {
      content = Align(
        alignment: Alignment.topLeft,
        child: content,
      );
    }

    if (themeProviders != null) {
      content = MultiProvider(
        providers: themeProviders,
        child: content,
      );
    }

    return content;
  }
}

class _AppWidgetBaseTest extends StatelessWidget {
  final Widget widget;
  final double? width;
  final double? height;
  final double? textScaleFactor;
  final bool wrapInScaffold;

  /// When `true`, applies the legacy capture wrappers ([RepaintBoundary],
  /// [SizedBox], [MediaQuery]) around [widget]. Disabled when overlays are
  /// included at the Navigator level instead.
  final bool wrapForCapture;

  const _AppWidgetBaseTest({
    required this.widget,
    this.width,
    this.height,
    this.textScaleFactor,
    this.wrapInScaffold = true,
    this.wrapForCapture = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = widget;

    if (wrapForCapture) {
      content = RepaintBoundary(
        child: SizedBox(
          height: height,
          width: width,
          child: MediaQuery(
            data: textScaleFactor != null
                ? MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScaleFactor!),
                  )
                : MediaQuery.of(context),
            child: content,
          ),
        ),
      );
    }

    return wrapInScaffold ? Scaffold(body: content) : content;
  }
}
