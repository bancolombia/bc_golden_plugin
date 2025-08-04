import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bc_golden_configuration.dart';

class TestBase {
  static Widget appGoldenTest({
    required Widget widget,
    double? height,
    double? width,
    double? textScaleFactor,
    ThemeData? customTheme,
  }) {
    BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();

    Widget appWidget = MaterialApp(
      home: _AppWidgetBaseTest(
        widget: widget,
        height: height,
        width: width,
        textScaleFactor: textScaleFactor,
      ),
      theme: customTheme ?? bcGoldenConfiguration.themeData,
    );

    if (bcGoldenConfiguration.themeProvider != null) {
      appWidget = MaterialApp(
        home: MultiProvider(
          providers: bcGoldenConfiguration.themeProvider ?? [],
          child: _AppWidgetBaseTest(
            widget: widget,
            height: height,
            width: width,
            textScaleFactor: textScaleFactor,
          ),
        ),
        theme: customTheme ?? bcGoldenConfiguration.themeData,
      );
    }

    return appWidget;
  }
}

class _AppWidgetBaseTest extends StatelessWidget {
  final Widget widget;
  final double? width;
  final double? height;
  final double? textScaleFactor;

  const _AppWidgetBaseTest({
    required this.widget,
    this.width,
    this.height,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        child: SizedBox(
          height: height,
          width: width,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleFactor ?? 1),
            ),
            child: widget,
          ),
        ),
      ),
    );
  }
}
