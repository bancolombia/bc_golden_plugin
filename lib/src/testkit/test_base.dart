import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  }) {
    BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

    final Widget child = _AppWidgetBaseTest(
      widget: widget,
      height: height,
      width: width,
      textScaleFactor: textScaleFactor,
      wrapInScaffold: wrapInScaffold,
    );

    final bool hasThemeProvider = bcGoldenConfiguration.themeProvider != null;

    Widget appWidget = MaterialApp(
      key: key,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales ?? const <Locale>[Locale('en')],
      locale: locale,
      theme: customTheme ?? bcGoldenConfiguration.themeData,
      home: hasThemeProvider
          ? MultiProvider(
              providers: bcGoldenConfiguration.themeProvider ?? [],
              child: child,
            )
          : child,
    );

    if (appWrapper != null) {
      appWidget = appWrapper(appWidget);
    }

    return appWidget;
  }
}

class _AppWidgetBaseTest extends StatelessWidget {
  final Widget widget;
  final double? width;
  final double? height;
  final double? textScaleFactor;
  final bool wrapInScaffold;

  const _AppWidgetBaseTest({
    required this.widget,
    this.width,
    this.height,
    this.textScaleFactor,
    this.wrapInScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = RepaintBoundary(
      child: SizedBox(
        height: height,
        width: width,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor:
                textScaleFactor, //TextScaler.linear(textScaleFactor ?? 1),
          ),
          child: widget,
        ),
      ),
    );

    return wrapInScaffold ? Scaffold(body: content) : content;
  }
}
