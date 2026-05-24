import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/achievements/providers/achievements_provider.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';
import 'package:regain/shared/models/models.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final stats = ref.watch(statsProvider);
    final unlocked = achievements.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning.withOpacity(0.15), AppColors.accent.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.warning.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Text('🏅', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$unlocked / ${achievements.length} unlocked',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: unlocked / achievements.length,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Level ${stats.level} · ${stats.xp} XP total',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Unlocked
          if (unlocked > 0) ...[
            _SectionLabel('Unlocked (${unlocked})'),
            const SizedBox(height: 10),
            ...achievements.where((a) => a.unlocked).map((a) => _AchievementTile(achievement: a)),
            const SizedBox(height: 20),
          ],

          // Locked
          _SectionLabel('Locked (${achievements.length - unlocked})'),
          const SizedBox(height: 10),
          ...achievements.where((a) => !a.unlocked).map((a) => _AchievementTile(achievement: a)),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.warning.withOpacity(0.08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? AppColors.warning.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(children: [
        // Emoji badge
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked ? AppColors.warning.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
          ),
          child: Center(
            child: Text(
              achievement.emoji,
              style: TextStyle(fontSize: 22, color: unlocked ? null : Colors.transparent),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            unlocked ? achievement.title : '???',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: unlocked ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unlocked ? achievement.description : 'Keep studying to unlock',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(unlocked ? 0.55 : 0.3),
            ),
          ),
        ])),
        if (unlocked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
          )
        else
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey.withOpacity(0.3)),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
    ),
  );
}
