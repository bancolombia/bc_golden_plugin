import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bcGoldenTest(
    'animated_widget_with_custom_pump',
    (tester) async {
      // Example animated widget that might cause timeout issues
      final animatedWidget = AnimatedContainer(
        duration: Duration(seconds: 2),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Animated',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      await bcWidgetMatchesImage(
        imageName: 'animated_widget_custom_pump',
        widget: animatedWidget,
        tester: tester,
        // Custom pump to handle animation without timeout
        customPump: () async {
          // Pump multiple times with smaller intervals to handle animation
          await tester.pump(Duration(milliseconds: 100));
          await tester.pump(Duration(milliseconds: 100));
          await tester.pump(Duration(milliseconds: 100));
        },
      );
    },
  );

  bcGoldenTest(
    'animated_widget_with_extended_timeout',
    (tester) async {
      // Example with longer timeout for complex animations
      final complexAnimatedWidget = AnimatedContainer(
        duration: Duration(seconds: 5),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );

      await bcWidgetMatchesImage(
        imageName: 'complex_animated_widget',
        widget: complexAnimatedWidget,
        tester: tester,
        // Extended timeout to allow complex animations to settle
        pumpTimeout: Duration(seconds: 30),
      );
    },
  );

  bcGoldenTest(
    'backward_compatibility_test',
    (tester) async {
      // Example showing backward compatibility - no new parameters needed
      final simpleWidget = Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 50,
        ),
      );

      await bcWidgetMatchesImage(
        imageName: 'simple_widget_backward_compat',
        widget: simpleWidget,
        tester: tester,
        // No customPump or pumpTimeout parameters - uses defaults
      );
    },
  );
}