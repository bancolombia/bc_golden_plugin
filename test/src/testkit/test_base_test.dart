import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  testWidgets('renders the widget with size, scale and custom theme',
      (tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      TestBase.appGoldenTest(
        widget: Container(),
        height: 200,
        width: 200,
        textScaleFactor: 1.5,
        customTheme: ThemeData(primaryColor: Colors.blue),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(Container), findsOneWidget);
  });

  group('with BcGoldenConfiguration theme', () {
    setUp(() async {
      final BcGoldenConfiguration bcGoldenConfiguration =
          BcGoldenConfiguration();
      bcGoldenConfiguration.themeData = ThemeData(primaryColor: Colors.red);
      await loadConfiguration();
    });

    testWidgets('renders using the configured theme data', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: Container(),
          height: 200,
          width: 200,
          textScaleFactor: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Container), findsOneWidget);
    });
  });

  group('localization support', () {
    testWidgets(
        'applies the given localizationsDelegates, supportedLocales and locale',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: const _LocalizedText(),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const <Locale>[Locale('es'), Locale('en')],
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: the MaterialApp received the configured locale.
      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.locale, const Locale('es'));
      expect(app.supportedLocales, const <Locale>[Locale('es'), Locale('en')]);
      expect(app.localizationsDelegates, isNotNull);
    });

    testWidgets(
        'combines localization, appWrapper and wrapInScaffold for a full screen',
        (tester) async {
      // Arrange: mirror what bcWidgetMatchesImage forwards for an i18n screen
      // with injected state that already brings its own scaffold.
      const Key wrapperKey = Key('scope');

      // Act
      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: const Scaffold(body: _LocalizedText()),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const <Locale>[Locale('es'), Locale('en')],
          locale: const Locale('es'),
          appWrapper: (final Widget app) =>
              Container(key: wrapperKey, child: app),
          wrapInScaffold: false,
        ),
      );
      await tester.pumpAndSettle();

      // Assert: wrapper present, single scaffold (the widget's own), and the
      // localized string resolved.
      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.locale, const Locale('es'));
      expect(find.byKey(wrapperKey), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(_LocalizedText), findsOneWidget);
    });
  });

  group('appWrapper injection', () {
    testWidgets('wraps the app with the provided builder', (tester) async {
      // Arrange
      const Key wrapperKey = Key('external_wrapper');

      // Act
      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: Container(),
          appWrapper: (final Widget app) => Container(
            key: wrapperKey,
            child: app,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: the external wrapper is present and contains the app.
      expect(find.byKey(wrapperKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(wrapperKey),
          matching: find.byType(MaterialApp),
        ),
        findsOneWidget,
      );
    });
  });

  group('wrapInScaffold', () {
    testWidgets('wraps the widget in a Scaffold by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestBase.appGoldenTest(widget: const Text('content')),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('omits the Scaffold when wrapInScaffold is false',
        (tester) async {
      // Arrange & Act: a full screen already provides its own Scaffold.
      await tester.pumpWidget(
        TestBase.appGoldenTest(
          widget: const Scaffold(body: Text('own scaffold')),
          wrapInScaffold: false,
        ),
      );
      await tester.pumpAndSettle();

      // Assert: only the widget's own Scaffold is present (no double Scaffold).
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('own scaffold'), findsOneWidget);
    });
  });

  group('dialog overlays', () {
    testWidgets(
      'with includeOverlays, showDialog is visible and can read themeProvider',
      (tester) async {
        // Arrange: register a provider that dialogs must be able to read.
        final BcGoldenConfiguration configuration = BcGoldenConfiguration();
        configuration.themeProvider = <SingleChildWidget>[
          Provider<String>.value(value: 'from-provider'),
        ];
        addTearDown(() => configuration.themeProvider = null);

        await tester.pumpWidget(
          TestBase.appGoldenTest(
            widget: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    content: Text(dialogContext.read<String>()),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
            width: 200,
            height: 200,
            includeOverlays: true,
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        // Assert: dialog is mounted inside the screenshot boundary with
        // provider access (sibling routes of `home` used to sit outside both).
        expect(find.text('from-provider'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(RepaintBoundary),
            matching: find.byType(AlertDialog),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'without includeOverlays, dialog cannot read themeProvider',
      (tester) async {
        final BcGoldenConfiguration configuration = BcGoldenConfiguration();
        configuration.themeProvider = <SingleChildWidget>[
          Provider<String>.value(value: 'from-provider'),
        ];
        addTearDown(() => configuration.themeProvider = null);

        await tester.pumpWidget(
          TestBase.appGoldenTest(
            widget: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    content: Text(dialogContext.read<String>()),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        // Legacy tree: dialog is a sibling route of home, outside MultiProvider.
        expect(tester.takeException(), isA<ProviderNotFoundException>());
      },
    );
  });
}

/// A minimal widget that reads a localized string to verify that localization
/// is wired up correctly by [TestBase.appGoldenTest].
class _LocalizedText extends StatelessWidget {
  const _LocalizedText();

  @override
  Widget build(final BuildContext context) {
    return Text(MaterialLocalizations.of(context).okButtonLabel);
  }
}
