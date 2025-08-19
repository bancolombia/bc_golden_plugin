import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Establish a subtree in which adaptive window resolves to the given data.
/// Use `WindowConfig.of(context)` to retrieve the data in any child widget.
///
/// See also: [WindowConfigData].
class WindowConfig extends InheritedWidget {
  const WindowConfig({
    required super.child,
    required this.windowConfig,
    super.key,
  });

  final WindowConfigData windowConfig;

  static WindowConfigData of(BuildContext context) {
    final WindowConfigData? result = context
        .dependOnInheritedWidgetOfExactType<WindowConfig>()
        ?.windowConfig;
    assert(result != null, 'No WindowConfig found in context');

    return result ??
        WindowConfigData(
          'unknown',
          size: Size.zero,
          pixelDensity: 1,
          targetPlatform: TargetPlatform.android,
          borderRadius: BorderRadius.zero,
          safeAreaPadding: EdgeInsets.zero,
        );
  }

  @override
  bool updateShouldNotify(WindowConfig oldWidget) =>
      oldWidget.windowConfig != windowConfig;
}

/// A Data class that describe a device properties that will impact design.
class WindowConfigData extends Equatable {
  WindowConfigData(
    this.name, {
    required this.size,
    required this.pixelDensity,
    required this.targetPlatform,
    required this.borderRadius,
    required EdgeInsets safeAreaPadding,
    this.keyboardSize,
    this.notchSize,
  })  : viewInsets = WindowPaddingImpl(
              bottom: keyboardSize?.height ?? 0,
            ) *
            pixelDensity,
        padding = WindowPaddingImpl(
              bottom: safeAreaPadding.bottom,
              top: safeAreaPadding.top,
            ) *
            pixelDensity,
        physicalSize = size * pixelDensity;

  final String name;

  /// Describes the size of the physical screen of the device in `dp`.
  final Size size;

  /// Describe the pixel density of the device.
  ///
  /// For iOS, this translates to the `@2x` and `@3x` annotations.
  final double pixelDensity;

  /// Describes the size of virtual keyboard of the device in `dp`.
  ///
  /// This is null when the device hasn't a virtual keyboard.
  final Size? keyboardSize;

  /// Describe the size of the device physical screen top notch in `dp`.
  ///
  /// This is null when the device has no notch.
  final Size? notchSize;

  /// Device Platform.
  ///
  /// See: [TargetPlatform].
  final TargetPlatform targetPlatform;

  /// This border radius describe the physical rounded corner of a device.
  final BorderRadius borderRadius;

  /// This padding describe the size used by an opened keyboard
  ///
  /// expressed in `px`.
  final FakeViewPadding viewInsets;

  /// This padding describe the size taken by the hardware layer.
  /// Like the notch on the iPhone X
  /// expressed in `px`.
  final FakeViewPadding padding;

  /// This represent the size of the device, expressed in `px`.
  final Size physicalSize;

  @override
  List<Object?> get props => [
        name,
        size,
        pixelDensity,
        keyboardSize,
        notchSize,
        targetPlatform,
        borderRadius,
        viewInsets,
        padding,
        physicalSize,
      ];
}

/// Implementation of the abstract class [FakeViewPadding].
class WindowPaddingImpl implements FakeViewPadding {
  const WindowPaddingImpl({
    this.bottom = 0,
    this.top = 0,
    this.left = 0,
    this.right = 0,
  });

  static const WindowPaddingImpl zero = WindowPaddingImpl();

  @override
  final double bottom;

  @override
  final double top;

  @override
  final double left;

  @override
  final double right;

  /// Multiplication operator.
  ///
  /// Returns a [WindowPaddingImpl] whose dimensions are the dimensions of the
  /// left-hand-side operand (a [WindowPaddingImpl]) multiplied by the scalar
  /// right-hand-side operand (a [double]).
  WindowPaddingImpl operator *(double operand) => WindowPaddingImpl(
        bottom: bottom * operand,
        top: top * operand,
        left: left * operand,
        right: right * operand,
      );
}

extension WindowPaddingX on FakeViewPadding {
  FakeViewPadding copyWith({
    double? bottom,
    double? top,
    double? left,
    double? right,
  }) {
    return WindowPaddingImpl(
      bottom: bottom ?? this.bottom,
      top: top ?? this.top,
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }
}
