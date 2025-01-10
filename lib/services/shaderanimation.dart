import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:google_fonts/google_fonts.dart';

class ShaderAnimationWidget extends StatefulWidget {
  const ShaderAnimationWidget({super.key});

  @override
  State<ShaderAnimationWidget> createState() => _ShaderAnimationWidgetState();
}

class _ShaderAnimationWidgetState extends State<ShaderAnimationWidget>
    with SingleTickerProviderStateMixin {
  Offset position = Offset.zero;
  Offset desiredPosition = Offset.zero;
  Offset velocity = Offset.zero;
  late final Ticker ticker;
  Duration lastTime = Duration.zero;

  late ui.FragmentProgram rgbSplitShader;
  late ui.FragmentProgram motionBlurShader;

  int currentEffectIndex = 0; // 0 for RGB Split, 1 for Motion Blur

  @override
  void initState() {
    super.initState();
    ticker = createTicker(onUpdate)..start();
    loadShaders();
  }

  Future<void> loadShaders() async {
    rgbSplitShader = await ui.FragmentProgram.fromAsset('assets/shaders/rgb.frag');
    motionBlurShader = await ui.FragmentProgram.fromAsset('assets/shaders/blur.frag');
    setState(() {}); // Trigger a rebuild after shaders are loaded
  }

  @override
  void dispose() {
    ticker.stop();
    ticker.dispose();
    super.dispose();
  }

  void onUpdate(Duration elapsed) {
    final delta = ((elapsed.inMicroseconds - lastTime.inMicroseconds) /
            Duration.microsecondsPerSecond) *
        60;

    lastTime = elapsed;

    if (desiredPosition == position) {
      return;
    }

    setState(() {
      final distance = desiredPosition - position;
      final amplitude = 1 - max(0, 1000 - distance.distance) / 1000;
      velocity =
          distance * (0.02 + 0.2 * Curves.easeInOut.transform(amplitude));

      position += velocity * delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (rgbSplitShader == null || motionBlurShader == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentShader = currentEffectIndex == 0 ? rgbSplitShader : motionBlurShader;

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          desiredPosition = details.globalPosition;
          position = details.globalPosition;
        });
      },
      onPanUpdate: (event) {
        setState(() {
          desiredPosition = event.globalPosition;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            AnimatedSampler(
              (image, size, canvas) {
                final shader = currentShader.fragmentShader();
                shader.setFloat(0, size.width);
                shader.setFloat(1, size.height);
                shader.setFloat(2, desiredPosition.dx);
                shader.setFloat(3, desiredPosition.dy);
                shader.setFloat(4, velocity.dx * 40);
                shader.setFloat(5, velocity.dy * 40);
                shader.setImageSampler(0, image);

                canvas.drawRect(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  Paint()..shader = shader,
                );
              },
              child: Center(
                child: Text(
                  "Hello World! " * 21,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Option(
                        title: const Text('RGB Split Distortion'),
                        selected: currentEffectIndex == 0,
                        onTap: () {
                          setState(() {
                            currentEffectIndex = 0;
                          });
                        },
                      ),
                      Option(
                        title: const Text('Motion Blur'),
                        selected: currentEffectIndex == 1,
                        onTap: () {
                          setState(() {
                            currentEffectIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Option extends StatelessWidget {
  const Option({
    super.key,
    required this.title,
    this.onTap,
    this.selected = false,
  });

  final Widget title;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: title),
            if (selected)
              const Icon(
                Icons.check,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
