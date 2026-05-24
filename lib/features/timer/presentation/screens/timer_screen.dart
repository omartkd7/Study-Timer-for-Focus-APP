import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/timer/providers/timer_provider.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';
import 'package:regain/features/goals/providers/goals_provider.dart';
import 'package:regain/features/music/providers/music_provider.dart';
import 'package:regain/features/tasks/providers/tasks_provider.dart';
import 'package:regain/shared/models/models.dart';
import '../widgets/circular_timer_painter.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  Color _modeColor(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:      return AppColors.focus;
      case TimerMode.shortBreak: return AppColors.shortBreak;
      case TimerMode.longBreak:  return AppColors.longBreak;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer    = ref.watch(timerProvider);
    final settings = ref.watch(settingsProvider);
    final stats    = ref.watch(statsProvider);
    final goal     = ref.watch(dailyGoalProvider);
    final music    = ref.watch(musicProvider);
    final tasks    = ref.watch(tasksProvider);
    final color    = _modeColor(timer.mode);

    final activeTask = timer.activeTaskId != null
        ? tasks.where((t) => t.id == timer.activeTaskId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: RichText(text: TextSpan(children: [
          TextSpan(text: 'Re', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          TextSpan(text: 'gain', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
        ])),
        actions: [
          // Music indicator
          if (music.isPlaying)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.music_note, size: 12, color: AppColors.info),
                const SizedBox(width: 3),
                Text(ambientTracks.firstWhere((t) => t.id == music.activeTrackId, orElse: () => ambientTracks.first).name,
                    style: const TextStyle(fontSize: 11, color: AppColors.info)),
              ]),
            ),
          // XP badge
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.bolt, size: 14, color: color),
              const SizedBox(width: 3),
              Text('${stats.xp} XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ]),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            // Mode tabs
            Row(mainAxisAlignment: MainAxisAlignment.center, children: TimerMode.values.map((m) {
              final sel = m == timer.mode;
              final c = _modeColor(m);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: GestureDetector(
                  onTap: () { if (!sel) ref.read(timerProvider.notifier).reset(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? c.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? c : c.withValues(alpha: 0.3), width: sel ? 1.5 : 1),
                    ),
                    child: Text(m.label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? c : c.withValues(alpha: 0.5))),
                  ),
                ),
              );
            }).toList()),

            // Streak
            if (stats.currentStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.local_fire_department, size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${stats.currentStreak}-day streak', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ]),
              ),

            const SizedBox(height: 8),

            // Timer ring
            Expanded(child: Center(child: AspectRatio(aspectRatio: 1, child: LayoutBuilder(
              builder: (_, constraints) {
                final sz = constraints.maxWidth;
                return Stack(alignment: Alignment.center, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: sz * 0.78, height: sz * 0.78,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: timer.status == TimerStatus.running ? 0.07 : 0.04)),
                  ),
                  CustomPaint(
                    size: Size(sz, sz),
                    painter: CircularTimerPainter(progress: timer.progress, trackColor: color.withValues(alpha: 0.12), progressColor: color, strokeWidth: sz * 0.04),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(timer.formattedTime, style: TextStyle(fontSize: sz * 0.18, fontWeight: FontWeight.w200, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -2)),
                    const SizedBox(height: 4),
                    Text(timer.mode.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
                    const SizedBox(height: 8),
                    // Subject / task chip
                    GestureDetector(
                      onTap: () => _showSubjectPicker(context, ref, timer.subject),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.edit_outlined, size: 10, color: color.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(activeTask?.title ?? timer.subject, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
                        ]),
                      ),
                    ),
                  ]),
                ]);
              },
            )))),

            // Session dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(settings.sessionsBeforeLongBreak, (i) {
              final done = i < timer.completedSessions % settings.sessionsBeforeLongBreak;
              return Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? color : color.withValues(alpha: 0.2)));
            })),

            const SizedBox(height: 16),

            // Daily goal bar
            _DailyGoalBar(goal: goal, color: color),

            const SizedBox(height: 16),

            // Controls
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Music
              IconButton(
                onPressed: () => context.go('/music'),
                icon: const Icon(Icons.music_note_outlined),
                style: IconButton.styleFrom(foregroundColor: music.isPlaying ? AppColors.info : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 8),
              // Reset
              IconButton(
                onPressed: () => ref.read(timerProvider.notifier).reset(),
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 8),
              // Play/Pause
              GestureDetector(
                onTap: () {
                  final n = ref.read(timerProvider.notifier);
                  timer.status == TimerStatus.running ? n.pause() : n.start();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72, height: 72,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Icon(timer.status == TimerStatus.running ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              // Skip
              IconButton(
                onPressed: () => ref.read(timerProvider.notifier).skip(),
                icon: const Icon(Icons.skip_next_rounded),
                style: IconButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 8),
              // Tasks
              IconButton(
                onPressed: () => context.go('/tasks'),
                icon: const Icon(Icons.checklist_rounded),
                style: IconButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
            ]),

            const SizedBox(height: 14),

            // Today stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _TodayStat('${stats.todayMinutes ~/ 60 > 0 ? "${stats.todayMinutes ~/ 60}h " : ""}${stats.todayMinutes % 60}m', 'Today', color),
                _TodayStat('${stats.totalSessions}', 'Sessions', color),
                _TodayStat('${stats.level}', 'Level', color),
              ]),
            ),
            const SizedBox(height: 14),
          ]),
        ),
      ),
    );
  }

  void _showSubjectPicker(BuildContext context, WidgetRef ref, String current) {
    const subjects = ['Study', 'Math', 'Science', 'Language', 'Coding', 'Reading', 'History', 'Art', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What are you studying?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: subjects.map((s) {
            final sel = s == current;
            final sc  = SubjectColors.of(s);
            return GestureDetector(
              onTap: () { ref.read(timerProvider.notifier).setSubject(s); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? sc.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? sc : Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(s, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? sc : null)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _DailyGoalBar extends StatelessWidget {
  final DailyGoal goal;
  final Color color;
  const _DailyGoalBar({required this.goal, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Daily goal', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        Text('${goal.achievedMinutes}/${goal.targetMinutes}m', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: goal.isAchieved ? AppColors.success : color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: goal.progress,
          minHeight: 5,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(goal.isAchieved ? AppColors.success : color),
        ),
      ),
    ]);
  }
}

class _TodayStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _TodayStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
  ]);
}
