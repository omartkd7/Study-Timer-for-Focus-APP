import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';
import 'package:regain/features/goals/providers/goals_provider.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats    = ref.watch(statsProvider);
    final goal     = ref.watch(dailyGoalProvider);
    final settings = ref.watch(settingsProvider);

    // Build last 7 days bar data
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final key = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      final mins = stats.dailyMinutes[key] ?? 0;
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: mins.toDouble(),
          color: AppColors.primary,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true, toY: 150,
            color: AppColors.primary.withValues(alpha: 0.07),
          ),
        ),
      ]);
    });

    final dayLabels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final todayIdx  = now.weekday - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.go('/achievements'),
            tooltip: 'Achievements',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // XP level card
          _LevelCard(stats: stats),
          const SizedBox(height: 16),

          // Daily goal card
          _DailyGoalCard(goal: goal, onEditGoal: () => _showGoalPicker(context, ref, settings.dailyGoalMinutes)),
          const SizedBox(height: 16),

          // Metric grid
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _MetricCard(icon: Icons.local_fire_department_rounded, value: '${stats.currentStreak}', label: 'Day streak', color: AppColors.warning),
              _MetricCard(icon: Icons.timer_outlined,                value: '${stats.totalMinutes ~/ 60}h ${stats.totalMinutes % 60}m', label: 'Total focus', color: AppColors.focus),
              _MetricCard(icon: Icons.check_circle_outline_rounded,  value: '${stats.totalSessions}', label: 'Sessions done', color: AppColors.success),
              _MetricCard(icon: Icons.bolt_rounded,                  value: '${stats.xp}', label: 'Total XP', color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly bar chart
          Text('This week', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            height: 200,
            child: BarChart(BarChartData(
              maxY: 150,
              barGroups: days,
              gridData: FlGridData(
                show: true, drawVerticalLine: false, horizontalInterval: 50,
                getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 36, interval: 50,
                  getTitlesWidget: (v, _) => Text(v == 0 ? '' : '${v.toInt()}m', style: TextStyle(fontSize: 10, color: Colors.grey.withValues(alpha: 0.5))),
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = (todayIdx - (6 - v.toInt()) + 7) % 7;
                    final isToday = v.toInt() == 6;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(dayLabels[idx], style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isToday ? AppColors.primary : Colors.grey.withValues(alpha: 0.5),
                      )),
                    );
                  },
                )),
              ),
            )),
          ),
          const SizedBox(height: 20),

          // Recent sessions
          Text('Recent sessions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          if (stats.sessions.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.hourglass_empty_rounded, size: 40, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                Text('No sessions yet. Start focusing!', style: TextStyle(color: Colors.grey.withValues(alpha: 0.5))),
              ]),
            ))
          else
            ...stats.sessions.take(10).map((s) {
              final h  = '${s.startTime.hour.toString().padLeft(2,'0')}:${s.startTime.minute.toString().padLeft(2,'0')}';
              final sc = SubjectColors.of(s.subject);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.timer_outlined, color: sc, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.subject, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sc)),
                    Text(h, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                  ])),
                  Text('${s.durationMinutes}m', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sc)),
                ]),
              );
            }),
        ]),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref, int current) {
    final options = [30, 60, 90, 120, 150, 180, 240];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Set daily goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: options.map((m) {
            final sel = m == current;
            final h = m ~/ 60; final min = m % 60;
            final label = h > 0 ? (min > 0 ? '${h}h ${min}m' : '${h}h') : '${min}m';
            return GestureDetector(
              onTap: () { ref.read(settingsProvider.notifier).setDailyGoal(m); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(label, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.primary : null)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final StatsState stats;
  const _LevelCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('Level ${stats.level}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Text('${stats.xpInCurrentLevel} / 100 XP', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.levelProgress, minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text('${100 - stats.xpInCurrentLevel} XP to Level ${stats.level + 1}',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
      ]),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final dynamic goal;
  final VoidCallback onEditGoal;
  const _DailyGoalCard({required this.goal, required this.onEditGoal});

  @override
  Widget build(BuildContext context) {
    final color = goal.isAchieved ? AppColors.success : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Row(children: [
          Icon(goal.isAchieved ? Icons.emoji_events_rounded : Icons.flag_outlined, color: color, size: 20),
          const SizedBox(width: 8),
          Text('Daily goal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          const Spacer(),
          GestureDetector(
            onTap: onEditGoal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text('${goal.achievedMinutes}/${goal.targetMinutes}m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: goal.progress, minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (goal.isAchieved) ...[
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle, size: 14, color: AppColors.success),
            SizedBox(width: 4),
            Text('Goal achieved today!', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500)),
          ]),
        ],
      ]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
        ]),
      ]),
    );
  }
}
