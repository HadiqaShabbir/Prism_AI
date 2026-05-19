import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _rayCtrl;
  late AnimationController _textCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _scale;
  late Animation<double> _glow;
  late Animation<double> _rayOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _rayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _glow = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _rayOpacity = CurvedAnimation(parent: _rayCtrl, curve: Curves.easeOut);
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<double>(begin: 18, end: 0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _exitFade = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  void _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _rayCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3200));
    _glowCtrl.stop();
    await _exitCtrl.forward();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const OnboardingScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    _rayCtrl.dispose();
    _textCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitFade,
      builder: (context, child) =>
          Opacity(opacity: _exitFade.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_scale, _glow, _rayOpacity]),
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF185FA5)
                                    .withOpacity(0.35 * _glow.value),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: _rayOpacity.value,
                        child: Transform.scale(
                          scale: _scale.value,
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: RayPainter(_glow.value),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: _scale.value,
                        child: CustomPaint(
                          size: const Size(100, 120),
                          painter: PrismLogoPainter(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (context, _) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                              colors: [
                                Color(0xFF6FB3FF),
                                Color(0xFFFFFFFF),
                                Color(0xFF6FB3FF),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'PRISM AI',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Services. Instantly.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.45),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shared painters — used across screens
class PrismLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8F4FF), Color(0xFFB8D9F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final topPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.28)
      ..lineTo(w * 0.5, h * 0.42)
      ..lineTo(0, h * 0.28)
      ..close();
    canvas.drawPath(topPath, topPaint);

    final leftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5BA3D9), Color(0xFF2A7DC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final leftPath = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w * 0.5, h * 0.42)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.65)
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    final rightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A5EA0), Color(0xFF0C3D6E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final rightPath = Path()
      ..moveTo(w, h * 0.28)
      ..lineTo(w, h * 0.65)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.5, h * 0.42)
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawPath(topPath, edgePaint);
    canvas.drawPath(leftPath, edgePaint);
    canvas.drawPath(rightPath, edgePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class RayPainter extends CustomPainter {
  final double intensity;
  RayPainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF6FB3FF).withOpacity(0.18 * intensity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final start = Offset(
        center.dx + math.cos(angle) * 65,
        center.dy + math.sin(angle) * 65,
      );
      final end = Offset(
        center.dx + math.cos(angle) * 95,
        center.dy + math.sin(angle) * 95,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(RayPainter old) => old.intensity != intensity;
}
