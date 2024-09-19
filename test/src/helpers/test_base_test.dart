
import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:bc_golden_plugin/src/helpers/test_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test appGoldenTest', (tester) async {
    await tester.pumpWidget(
      BcGoldenBaseTest.appGoldenTest(
        widget: Container(),
        height: 200,
        width: 200,
        textScaleFactor: 1.5,
        customTheme: ThemeData(primaryColor: Colors.blue),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Container), findsOneWidget);
  });

  setUp(() async{
    BcGoldenConfiguration bcGoldenConfiguration = BcGoldenConfiguration();
    
    bcGoldenConfiguration.setThemeData = ThemeData(primaryColor: Colors.red);

    await loadConfiguration();
  });
  testWidgets('test appGoldenTest', (tester) async {
    await tester.pumpWidget(
      BcGoldenBaseTest.appGoldenTest(
        widget: Container(),
        height: 200,
        width: 200,
        textScaleFactor: 1.5,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Container), findsOneWidget);
  });

}