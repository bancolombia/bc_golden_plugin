import '../golden_configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BcGoldenBaseTest {
  static Widget appGoldenTest({
    required Widget widget,
    double? height,
    double? width,
    double? textScaleFactor,
    ThemeData? customTheme,
  }) {
    BcGoldenConfiguration _bcGoldenConfiguration = BcGoldenConfiguration();

    Widget _appWidget = MaterialApp(
      home: _AppWidgetBaseTest(
        widget: widget,
        height: height,
        width: width,
        textScaleFactor: textScaleFactor,
      ),
      theme: customTheme ?? _bcGoldenConfiguration.themeData,
    );

    if (_bcGoldenConfiguration.themeProvider != null) {
      _appWidget = MaterialApp(
        home: MultiProvider(
          providers: _bcGoldenConfiguration.themeProvider!,
          child: _AppWidgetBaseTest(
            widget: widget,
            height: height,
            width: width,
            textScaleFactor: textScaleFactor,
          ),
        ),
        theme: customTheme ?? _bcGoldenConfiguration.themeData,
      );
    }

    return _appWidget;
  }
}

class _AppWidgetBaseTest extends StatelessWidget {
  final Widget widget;
  final double? width;
  final double? height;
  final double? textScaleFactor;

  const _AppWidgetBaseTest({
    Key? key,
    required this.widget,
    this.width,
    this.height,
    this.textScaleFactor,
  }) : super(key: key);

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
