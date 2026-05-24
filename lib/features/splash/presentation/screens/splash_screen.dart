import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/core/constants/app_constants.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _ringAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;

  final _quote = AppConstants.quotes[Random().nextInt(AppConstants.quotes.length)];

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _progressCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      final settings = ref.read(settingsProvider);
      context.go(settings.onboardingDone ? '/timer' : '/onboarding');
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _fadeCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated ring + logo
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, __) => SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _SplashRingPainter(_ringAnim.value),
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: RichText(
                          text: const TextSpan(children: [
                            TextSpan(text: 'Re', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            TextSpan(text: 'gain', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Quote
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  _quote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14, color: Colors.white54,
                    fontStyle: FontStyle.italic, height: 1.6,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Progress bar
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        minHeight: 3,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Study Timer for Focus',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3), letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashRingPainter extends CustomPainter {
  final double progress;
  _SplashRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;

    // Track
    canvas.drawCircle(c, r, Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke);

    // Animated arc
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dot tip
    if (progress > 0.02) {
      final angle = -pi / 2 + 2 * pi * progress;
      canvas.drawCircle(
        Offset(c.dx + r * cos(angle), c.dy + r * sin(angle)),
        4,
        Paint()..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(_SplashRingPainter old) => old.progress != progress;
}
