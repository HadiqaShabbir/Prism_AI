import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _illustrationCtrl;
  late Animation<double> _illustrationScale;
  late Animation<double> _illustrationFade;

  final List<_OnboardSlide> _slides = [
    _OnboardSlide(
      illustrationWidget: const _IllustrationSearch(),
      title: 'Find Any Service',
      subtitle:
          'Speak in Urdu, Roman Urdu, or English. Our AI listens and understands exactly what you need.',
      accentColor: const Color(0xFF185FA5),
      bgGradient: const [Color(0xFFF0F7FF), Color(0xFFE0EEFF)],
    ),
    _OnboardSlide(
      illustrationWidget: const _IllustrationMatch(),
      title: 'AI Picks the Best',
      subtitle:
          'Providers are ranked by distance, rating, and availability to help you find the right match.',
      accentColor: const Color(0xFF0C447C),
      bgGradient: const [Color(0xFFEDF4FF), Color(0xFFD6E8FF)],
    ),
    _OnboardSlide(
      illustrationWidget: const _IllustrationBook(),
      title: 'Book and Relax',
      subtitle:
          'Instant confirmation, real-time tracking, and reminders. We handle it all.',
      accentColor: const Color(0xFF1A6BC4),
      bgGradient: const [Color(0xFFF5F9FF), Color(0xFFDCECFF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _illustrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _illustrationScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _illustrationCtrl, curve: Curves.easeOutBack),
    );
    _illustrationFade = CurvedAnimation(
      parent: _illustrationCtrl,
      curve: Curves.easeOut,
    );
    _illustrationCtrl.forward();
  }

  @override
  void dispose() {
    _illustrationCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _currentPage = idx);
    _illustrationCtrl.reset();
    _illustrationCtrl.forward();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.bgGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 26,
                          height: 32,
                          child: CustomPaint(painter: PrismLogoPainter()),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRISM AI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: slide.accentColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF888780),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Skip', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final s = _slides[index];
                    return AnimatedBuilder(
                      animation: _illustrationCtrl,
                      builder: (context, _) => Opacity(
                        opacity: _currentPage == index
                            ? _illustrationFade.value
                            : 1.0,
                        child: Transform.scale(
                          scale: _currentPage == index
                              ? _illustrationScale.value
                              : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: s.illustrationWidget,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? slide.accentColor
                                  : const Color(0xFFBDD5EE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          slide.title,
                          key: ValueKey(slide.title),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          slide.subtitle,
                          key: ValueKey(slide.subtitle),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7A8D),
                            height: 1.65,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: slide.accentColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: slide.accentColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _slides.length - 1
                                    ? 'Next'
                                    : 'Get Started',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < _slides.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.check_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final Widget illustrationWidget;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<Color> bgGradient;

  const _OnboardSlide({
    required this.illustrationWidget,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.bgGradient,
  });
}

// ── Illustrations ────────────────────────────

class _IllustrationSearch extends StatefulWidget {
  const _IllustrationSearch();

  @override
  State<_IllustrationSearch> createState() => _IllustrationSearchState();
}

class _IllustrationSearchState extends State<_IllustrationSearch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, _) => Transform.translate(
        offset: Offset(0, _float.value),
        child: CustomPaint(
          painter: _SearchPainter(),
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

class _SearchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - 10),
        width: size.width * 0.82,
        height: size.height * 0.72,
      ),
      Paint()..color = const Color(0xFF185FA5).withOpacity(0.08),
    );

    final phoneShadow = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 5), width: 140, height: 240),
      const Radius.circular(24),
    );
    canvas.drawRRect(phoneRect, phoneShadow);
    canvas.drawRRect(phoneRect, Paint()..color = Colors.white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 5), width: 118, height: 198),
        const Radius.circular(20),
      ),
      Paint()
        ..shader =
            const LinearGradient(
              colors: [Color(0xFFEEF5FF), Color(0xFFDCEBFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy - 5),
                width: 118,
                height: 198,
              ),
            ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 48, cy - 80, 96, 28),
        const Radius.circular(14),
      ),
      Paint()..color = Colors.white,
    );

    final searchIcon = Paint()
      ..color = const Color(0xFF185FA5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx - 32, cy - 66), 7, searchIcon);
    canvas.drawLine(
      Offset(cx - 27, cy - 61),
      Offset(cx - 23, cy - 57),
      searchIcon,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.15)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final y = cy - 38 + i * 20.0;
      final w = i % 2 == 0 ? 70.0 : 50.0;
      canvas.drawLine(Offset(cx - 46, y), Offset(cx - 46 + w, y), linePaint);
    }

    _drawStar(
      canvas,
      Offset(cx + 38, cy - 90),
      8,
      Paint()..color = const Color(0xFF185FA5),
    );
    _drawStar(
      canvas,
      Offset(cx - 55, cy - 50),
      5,
      Paint()..color = const Color(0xFF6FB3FF),
    );
    _drawStar(
      canvas,
      Offset(cx + 55, cy + 30),
      6,
      Paint()..color = const Color(0xFF3A8FD6),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 4;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final midAngle = (i - 0.5) * math.pi / 2 - math.pi / 4;
        path.lineTo(
          center.dx + math.cos(midAngle) * size * 0.4,
          center.dy + math.sin(midAngle) * size * 0.4,
        );
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _IllustrationMatch extends StatefulWidget {
  const _IllustrationMatch();

  @override
  State<_IllustrationMatch> createState() => _IllustrationMatchState();
}

class _IllustrationMatchState extends State<_IllustrationMatch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => CustomPaint(
        painter: _MatchPainter(_pulse.value),
        child: const SizedBox(width: double.infinity, height: double.infinity),
      ),
    );
  }
}

class _MatchPainter extends CustomPainter {
  final double pulse;
  _MatchPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.8,
        height: size.height * 0.68,
      ),
      Paint()..color = const Color(0xFF0C447C).withOpacity(0.08),
    );

    canvas.drawCircle(
      Offset(cx, cy),
      52.0 + 8 * pulse,
      Paint()..color = const Color(0xFF185FA5).withOpacity(0.08 - 0.04 * pulse),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      48,
      Paint()..color = const Color(0xFF185FA5),
    );

    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy - 4), 14, iconPaint);
    canvas.drawLine(
      Offset(cx - 14, cy - 4),
      Offset(cx - 22, cy - 4),
      iconPaint,
    );
    canvas.drawLine(
      Offset(cx + 14, cy - 4),
      Offset(cx + 22, cy - 4),
      iconPaint,
    );
    canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy + 20), iconPaint);
    canvas.drawLine(Offset(cx, cy + 20), Offset(cx - 6, cy + 26), iconPaint);
    canvas.drawLine(Offset(cx, cy + 20), Offset(cx + 6, cy + 26), iconPaint);

    _drawCard(canvas, Offset(cx, cy - 120), '4.9', 'Electrician', pulse);
    _drawCard(canvas, Offset(cx + 110, cy + 30), '4.7', 'Plumber', pulse);
    _drawCard(canvas, Offset(cx - 110, cy + 30), '4.8', 'Cleaner', pulse);

    final linePaint = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.2)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, cy - 48), Offset(cx, cy - 90), linePaint);
    canvas.drawLine(
      Offset(cx + 42, cy + 24),
      Offset(cx + 85, cy + 40),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx - 42, cy + 24),
      Offset(cx - 85, cy + 40),
      linePaint,
    );
  }

  void _drawCard(
    Canvas canvas,
    Offset center,
    String rating,
    String label,
    double pulse,
  ) {
    final shadow = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 86, height: 38),
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, shadow);
    canvas.drawRRect(rect, Paint()..color = Colors.white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 43, center.dy - 19, 4, 38),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF185FA5),
    );

    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$rating\n',
            style: const TextStyle(
              color: Color(0xFF185FA5),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(color: Color(0xFF6B7A8D), fontSize: 9),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: 68);
    tp.paint(canvas, Offset(center.dx - 34, center.dy - 15));
  }

  @override
  bool shouldRepaint(_MatchPainter old) => old.pulse != pulse;
}

class _IllustrationBook extends StatefulWidget {
  const _IllustrationBook();

  @override
  State<_IllustrationBook> createState() => _IllustrationBookState();
}

class _IllustrationBookState extends State<_IllustrationBook>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _tick;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _tick = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tick,
      builder: (_, _) => CustomPaint(
        painter: _BookPainter(_tick.value),
        child: const SizedBox(width: double.infinity, height: double.infinity),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  final double t;
  _BookPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 10),
        width: size.width * 0.78,
        height: size.height * 0.65,
      ),
      Paint()..color = const Color(0xFF1A6BC4).withOpacity(0.08),
    );

    final shadow = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 200, height: 190),
      const Radius.circular(22),
    );
    canvas.drawRRect(card, shadow);
    canvas.drawRRect(card, Paint()..color = Colors.white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 100, cy - 85, 200, 46),
        const Radius.circular(22),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF185FA5), Color(0xFF1A6BC4)],
        ).createShader(Rect.fromLTWH(cx - 100, cy - 85, 200, 46)),
    );

    final headerText = TextPainter(
      text: const TextSpan(
        text: 'Booking Confirmed',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    headerText.paint(canvas, Offset(cx - headerText.width / 2, cy - 73));

    canvas.drawCircle(
      Offset(cx, cy - 22),
      22,
      Paint()..color = const Color(0xFF4CAF50),
    );

    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(cx - 10, cy - 22)
      ..lineTo(cx - 3, cy - 15)
      ..lineTo(cx + 11, cy - 30);
    canvas.drawPath(checkPath, checkPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF185FA5).withOpacity(0.18)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final positions = [cy + 12, cy + 28, cy + 44, cy + 60];
    final widths = [90.0, 65.0, 80.0, 55.0];
    for (int i = 0; i < positions.length; i++) {
      canvas.drawLine(
        Offset(cx - 70, positions[i]),
        Offset(cx - 70 + widths[i], positions[i]),
        linePaint,
      );
    }

    final notifOffset = Offset(cx + 78, cy - 80 + 4 * math.sin(t * math.pi));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: notifOffset, width: 64, height: 30),
        const Radius.circular(15),
      ),
      Paint()..color = const Color(0xFF4CAF50),
    );
    final notifText = TextPainter(
      text: const TextSpan(
        text: 'Ready',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    notifText.paint(
      canvas,
      Offset(notifOffset.dx - notifText.width / 2, notifOffset.dy - 7),
    );
  }

  @override
  bool shouldRepaint(_BookPainter old) => old.t != t;
}
