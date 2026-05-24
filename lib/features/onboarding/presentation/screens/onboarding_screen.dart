import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '⏱️',
      title: 'Focus with\nPomodoro',
      body: 'Work in 25-minute sprints with short breaks. Proven to maximize concentration and reduce burnout.',
      color: AppColors.primary,
    ),
    _OnboardPage(
      emoji: '📊',
      title: 'Track your\nprogress',
      body: 'See your daily focus time, streaks, and XP grow. Analytics that motivate you to keep going.',
      color: AppColors.success,
    ),
    _OnboardPage(
      emoji: '🏆',
      title: 'Compete &\nachieve',
      body: 'Climb the leaderboard, unlock badges, and challenge yourself with daily goals.',
      color: AppColors.warning,
    ),
    _OnboardPage(
      emoji: '🎵',
      title: 'Focus music\n& ambience',
      body: 'Choose from rain, forest, café, and more ambient sounds to stay in the zone.',
      color: AppColors.info,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    context.go('/timer');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = _pages[_page].color;
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: TextStyle(color: Colors.white38, fontSize: 14)),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _page == i ? color : Colors.white12,
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  // Next / Get started
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(backgroundColor: color),
                      child: Text(_page < _pages.length - 1 ? 'Next' : 'Get started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Color color;

  const _OnboardPage({required this.emoji, required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji in circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.white54, height: 1.65),
          ),
        ],
      ),
    );
  }
}
