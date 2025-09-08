import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  // Test de ejemplo simple para demostrar la funcionalidad
  BcGoldenCapture.animation(
    'Simple fade animation test',
    const SimpleFadeAnimation(),
    GoldenAnimationConfig(
      testName: 'simple_fade',
      totalDuration: const Duration(milliseconds: 500),
      animationSteps: const [
        GoldenAnimationStep(
          timestamp: Duration.zero,
          frameName: 'start_invisible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 290),
          frameName: 'half_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 320),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 340),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 360),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 380),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 400),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 420),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 440),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 460),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 480),
          frameName: 'fully_visible',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 500),
          frameName: 'fully_visible',
        ),
      ],
      layoutType: CaptureLayoutType.horizontal,
      spacing: 20.0,
      showTimelineLabels: true,
      device: GoldenDeviceData.iPhone13,
    ),
  );

  BcGoldenCapture.animation(
    'Loading spinner rotation',
    const CircularProgressIndicator(),
    const GoldenAnimationConfig(
      testName: 'spinner_rotation',
      totalDuration: Duration(milliseconds: 1000),
      showTimelineLabels: true,
      animationSteps: [
        GoldenAnimationStep(
          timestamp: Duration.zero,
          frameName: '0_degrees',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 250),
          frameName: '90_degrees',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 500),
          frameName: '180_degrees',
        ),
        GoldenAnimationStep(
          timestamp: Duration(milliseconds: 750),
          frameName: '270_degrees',
        ),
      ], // Mismos pasos
      layoutType: CaptureLayoutType.grid,
      maxScreensPerRow: 2,
    ),
  );
}

/// Widget de ejemplo simple con animación de fade
class SimpleFadeAnimation extends StatefulWidget {
  const SimpleFadeAnimation({super.key});

  @override
  State<SimpleFadeAnimation> createState() => _SimpleFadeAnimationState();
}

class _SimpleFadeAnimationState extends State<SimpleFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    // Iniciar la animación automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Fade Animation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
