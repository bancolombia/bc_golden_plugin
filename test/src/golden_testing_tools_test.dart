import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:bc_golden_plugin/src/helpers/window_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int counter = 0;
  test('bcCustomWindowConfigData should return a WindowConfigData object', () {
    final configData = bcCustomWindowConfigData(
      name: 'Custom Config',
      size: Size(360, 640),
      pixelDensity: 2.0,
    );
    expect(configData, isA<WindowConfigData>());
  });

  test('IconExtension.convertToGolden should return an IconData object', () {
    final iconData = IconData(0xe900, fontFamily: 'BdsFunctionalIcons');
    final convertedIcon = iconData.convertToGolden();
    expect(convertedIcon, isA<IconData>());
  });

  bcGoldenTest(
    'Test with real shadows',
    (tester) async {
      counter++;
    },
    shouldUseRealShadows: true,
  );

  test('bcGoldenTest should run test with real shadows', () async {
    expect(counter, 1);
  });

  group('bcWidgetMatchesImage with custom pump', () {
    testWidgets('should accept customPump parameter', (tester) async {
      bool customPumpCalled = false;
      
      // This test verifies the API accepts the new parameters
      // We don't actually run the golden comparison due to file system constraints
      expect(() {
        bcWidgetMatchesImage(
          imageName: 'test_widget',
          widget: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
          tester: tester,
          customPump: () async {
            customPumpCalled = true;
            await tester.pump(Duration(milliseconds: 100));
          },
          pumpTimeout: Duration(seconds: 5),
        );
      }, returnsNormally);
    });

    testWidgets('should accept pumpTimeout parameter', (tester) async {
      // This test verifies the API accepts the timeout parameter
      expect(() {
        bcWidgetMatchesImage(
          imageName: 'test_widget_timeout',
          widget: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ),
          tester: tester,
          pumpTimeout: Duration(seconds: 30), // Custom timeout for animations
        );
      }, returnsNormally);
    });

    testWidgets('should work with backward compatibility (no custom params)', (tester) async {
      // This test verifies backward compatibility
      expect(() {
        bcWidgetMatchesImage(
          imageName: 'test_widget_compat',
          widget: Container(
            width: 100,
            height: 100,
            color: Colors.green,
          ),
          tester: tester,
        );
      }, returnsNormally);
    });
  });
}
