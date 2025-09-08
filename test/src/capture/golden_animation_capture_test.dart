import 'dart:typed_data';

import 'package:bc_golden_plugin/bc_golden_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoldenAnimationCapture extension', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ColoredBox(
              color: Colors.blue,
              child: SizedBox(
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );
    });

    group('captureAnimation', () {
      testWidgets(
        'throws ArgumentError when config is invalid',
        (tester) async {
          const invalidConfig = GoldenAnimationConfig(
            testName: 'invalid_test',
            totalDuration: Duration(milliseconds: 100),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 200), // Beyond totalDuration
                frameName: 'invalid_step',
              ),
            ],
          );

          expect(
            () => tester.captureAnimation(testWidget, invalidConfig, null),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      testWidgets('captures animation with valid config', (tester) async {
        await tester.runAsync(() async {
          const config = GoldenAnimationConfig(
            testName: 'simple_animation',
            totalDuration: Duration(milliseconds: 300),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 0),
                frameName: 'start',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 150),
                frameName: 'middle',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 300),
                frameName: 'end',
              ),
            ],
          );

          final result =
              await tester.captureAnimation(testWidget, config, null);

          expect(result, isA<Uint8List>());
          expect(result.isNotEmpty, isTrue);
        });
      });

      testWidgets('executes animation setup function', (tester) async {
        await tester.runAsync(() async {
          bool setupCalled = false;

          const config = GoldenAnimationConfig(
            testName: 'setup_test',
            totalDuration: Duration(milliseconds: 100),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 0),
                frameName: 'frame',
              ),
            ],
          );

          await tester.captureAnimation(
            testWidget,
            config,
            (tester) async {
              setupCalled = true;
            },
          );

          expect(setupCalled, isTrue);
        });
      });

      testWidgets('executes step setup and verify actions', (tester) async {
        await tester.runAsync(() async {
          bool setupActionCalled = false;
          bool verifyActionCalled = false;

          final config = GoldenAnimationConfig(
            testName: 'actions_test',
            totalDuration: const Duration(milliseconds: 100),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: const Duration(milliseconds: 0),
                frameName: 'frame',
                setupAction: (tester) async {
                  setupActionCalled = true;
                },
                verifyAction: (tester) async {
                  verifyActionCalled = true;
                },
              ),
            ],
          );

          await tester.captureAnimation(testWidget, config, null);

          expect(setupActionCalled, isTrue);
          expect(verifyActionCalled, isTrue);
        });
      });

      testWidgets('sorts animation steps by timestamp', (tester) async {
        await tester.runAsync(() async {
          const config = GoldenAnimationConfig(
            testName: 'sorting_test',
            totalDuration: Duration(milliseconds: 300),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 200),
                frameName: 'second',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 0),
                frameName: 'first',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 100),
                frameName: 'middle',
              ),
            ],
          );

          // This should not throw and should handle the sorting internally
          final result =
              await tester.captureAnimation(testWidget, config, null);
          expect(result, isA<Uint8List>());
        });
      });

      testWidgets('handles single animation step', (tester) async {
        await tester.runAsync(() async {
          const config = GoldenAnimationConfig(
            testName: 'single_step',
            totalDuration: Duration(milliseconds: 100),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 50),
                frameName: 'only_frame',
              ),
            ],
          );

          final result =
              await tester.captureAnimation(testWidget, config, null);

          expect(result, isA<Uint8List>());
          expect(result.isNotEmpty, isTrue);
        });
      });

      testWidgets('handles zero duration steps', (tester) async {
        await tester.runAsync(() async {
          const config = GoldenAnimationConfig(
            testName: 'zero_duration',
            totalDuration: Duration(milliseconds: 100),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration.zero,
                frameName: 'start',
              ),
              GoldenAnimationStep(
                timestamp: Duration.zero, // Same timestamp
                frameName: 'also_start',
              ),
            ],
          );

          final result =
              await tester.captureAnimation(testWidget, config, null);
          expect(result, isA<Uint8List>());
        });
      });
    });

    group(
      'combineAnimationScreenshots',
      () {
        testWidgets(
          'throws ArgumentError when screenshots are empty',
          (tester) async {
            const config = GoldenAnimationConfig(
              testName: 'empty_test',
              totalDuration: Duration(milliseconds: 100),
              animationSteps: [
                GoldenAnimationStep(
                  timestamp: Duration.zero,
                  frameName: 'frame',
                ),
              ],
            );

            // Clear any existing screenshots
            tester.clearGoldenScreenshots();

            expect(
              () => tester.combineAnimationScreenshots(config, ['frame']),
              throwsA(isA<ArgumentError>()),
            );
          },
        );

        testWidgets('combines screenshots successfully', (tester) async {
          await tester.runAsync(() async {
            // First capture some screenshots
            await tester.pumpWidget(testWidget);
            await tester.pumpAndSettle();

            // Capture a few screenshots to test combination
            await tester.captureGoldenScreenshot();
            await tester.captureGoldenScreenshot();

            const config = GoldenAnimationConfig(
              testName: 'combine_test',
              totalDuration: Duration(milliseconds: 200),
              animationSteps: [
                GoldenAnimationStep(
                  timestamp: Duration.zero,
                  frameName: 'frame1',
                ),
                GoldenAnimationStep(
                  timestamp: Duration(milliseconds: 100),
                  frameName: 'frame2',
                ),
              ],
            );

            final result = await tester.combineAnimationScreenshots(
              config,
              ['frame1 - 0:00:00.000000', 'frame2 - 0:00:00.100000'],
            );

            expect(result, isA<Uint8List>());
            expect(result.isNotEmpty, isTrue);
          });
        });

        testWidgets(
          'handles large canvas dimensions with scaling',
          (tester) async {
            await tester.runAsync(() async {
              // Create a large widget that would exceed canvas limits
              final largeWidget = MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Container(
                      width: 2000,
                      height: 2000,
                      color: Colors.red,
                    ),
                  ),
                ),
              );

              await tester.pumpWidget(largeWidget);
              await tester.pumpAndSettle();

              // Capture multiple screenshots to force large canvas
              for (int i = 0; i < 3; i++) {
                await tester.captureGoldenScreenshot();
              }

              const config = GoldenAnimationConfig(
                testName: 'large_canvas_test',
                totalDuration: Duration(milliseconds: 300),
                animationSteps: [
                  GoldenAnimationStep(
                    timestamp: Duration.zero,
                    frameName: 'frame1',
                  ),
                  GoldenAnimationStep(
                    timestamp: Duration(milliseconds: 100),
                    frameName: 'frame2',
                  ),
                  GoldenAnimationStep(
                    timestamp: Duration(milliseconds: 200),
                    frameName: 'frame3',
                  ),
                ],
              );

              final result = await tester.combineAnimationScreenshots(
                config,
                [
                  'frame1 - 0:00:00.000000',
                  'frame2 - 0:00:00.100000',
                  'frame3 - 0:00:00.200000',
                ],
              );

              expect(result, isA<Uint8List>());
              expect(result.isNotEmpty, isTrue);
            });
          },
        );

        testWidgets(
          'handles many screenshots with grid layout',
          (tester) async {
            await tester.runAsync(() async {
              await tester.pumpWidget(testWidget);
              await tester.pumpAndSettle();

              // Capture more than 5 screenshots to trigger grid layout
              for (int i = 0; i < 7; i++) {
                await tester.captureGoldenScreenshot();
              }

              final config = GoldenAnimationConfig(
                testName: 'grid_layout_test',
                totalDuration: const Duration(milliseconds: 700),
                animationSteps: List.generate(
                  7,
                  (index) => GoldenAnimationStep(
                    timestamp: Duration(milliseconds: index * 100),
                    frameName: 'frame${index + 1}',
                  ),
                ),
                maxScreensPerRow: 3,
              );

              final stepNames = List.generate(
                7,
                (index) =>
                    'frame${index + 1} - 0:00:00.${(index * 100).toString().padLeft(6, '0')}',
              );

              final result =
                  await tester.combineAnimationScreenshots(config, stepNames);

              expect(result, isA<Uint8List>());
              expect(result.isNotEmpty, isTrue);
            });
          },
        );
      },
    );

    group('integration tests', () {
      testWidgets('complete animation capture workflow', (tester) async {
        await tester.runAsync(() async {
          final animatedWidget = MaterialApp(
            home: Scaffold(
              body: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
            ),
          );

          const config = GoldenAnimationConfig(
            testName: 'integration_test',
            totalDuration: Duration(milliseconds: 500),
            animationSteps: [
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 0),
                frameName: 'start',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 250),
                frameName: 'middle',
              ),
              GoldenAnimationStep(
                timestamp: Duration(milliseconds: 500),
                frameName: 'end',
              ),
            ],
            spacing: 20.0,
            maxScreensPerRow: 3,
          );

          final result = await tester.captureAnimation(
            animatedWidget,
            config,
            (tester) async {
              // Setup animation by triggering rebuild with animation
              await tester.pump();
            },
          );

          expect(result, isA<Uint8List>());
          expect(result.isNotEmpty, isTrue);

          // Verify that screenshots were captured
          expect(tester.goldenScreenshots.length, equals(3));
        });
      });

      testWidgets(
        'handles custom spacing and layout configuration',
        (tester) async {
          await tester.runAsync(() async {
            const config = GoldenAnimationConfig(
              testName: 'custom_spacing_test',
              totalDuration: Duration(milliseconds: 200),
              animationSteps: [
                GoldenAnimationStep(
                  timestamp: Duration(milliseconds: 0),
                  frameName: 'frame1',
                ),
                GoldenAnimationStep(
                  timestamp: Duration(milliseconds: 100),
                  frameName: 'frame2',
                ),
              ],
              spacing: 50.0,
              maxScreensPerRow: 2,
            );

            final result =
                await tester.captureAnimation(testWidget, config, null);

            expect(result, isA<Uint8List>());
            expect(result.isNotEmpty, isTrue);
          });
        },
      );
    });

    group('edge cases', () {
      testWidgets(
        'handles widget that changes size during animation',
        (tester) async {
          await tester.runAsync(() async {
            bool isLarge = false;

            final changingSizeWidget = StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLarge = !isLarge;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isLarge ? 200 : 100,
                          height: isLarge ? 200 : 100,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );

            final config = GoldenAnimationConfig(
              testName: 'changing_size_test',
              totalDuration: const Duration(milliseconds: 300),
              animationSteps: [
                GoldenAnimationStep(
                  timestamp: const Duration(milliseconds: 0),
                  frameName: 'small',
                  setupAction: (tester) async {
                    // Trigger size change
                    await tester.tap(find.byType(GestureDetector));
                    await tester.pump();
                  },
                ),
                const GoldenAnimationStep(
                  timestamp: Duration(milliseconds: 150),
                  frameName: 'transitioning',
                ),
                const GoldenAnimationStep(
                  timestamp: Duration(milliseconds: 300),
                  frameName: 'large',
                ),
              ],
            );

            final result =
                await tester.captureAnimation(changingSizeWidget, config, null);

            expect(result, isA<Uint8List>());
            expect(result.isNotEmpty, isTrue);
          });
        },
      );

      testWidgets('handles empty animation steps list', (tester) async {
        const config = GoldenAnimationConfig(
          testName: 'empty_steps',
          totalDuration: Duration(milliseconds: 100),
          animationSteps: [], // Empty list
        );

        // Empty list is valid but will throw when trying to combine
        expect(config.isValid, isTrue); // Empty list is valid

        await tester.runAsync(() async {
          // Should throw ArgumentError when trying to combine empty screenshots
          expect(
            () => tester.captureAnimation(testWidget, config, null),
            throwsA(isA<ArgumentError>()),
          );
        });
      });
    });
  });
}
