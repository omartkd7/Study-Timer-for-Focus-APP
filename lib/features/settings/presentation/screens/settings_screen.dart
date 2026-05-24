import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats    = ref.watch(statsProvider);
    final n        = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile summary
          _ProfileCard(stats: stats),
          const SizedBox(height: 20),

          _SectionLabel('Pomodoro timer'),
          const SizedBox(height: 10),
          _DurationRow(label: 'Focus duration', icon: Icons.timer_outlined, color: AppColors.focus,
              value: settings.focusDuration, min: 5, max: 90, step: 5, onChanged: n.setFocusDuration),
          const SizedBox(height: 8),
          _DurationRow(label: 'Short break', icon: Icons.coffee_outlined, color: AppColors.shortBreak,
              value: settings.shortBreak, min: 1, max: 30, step: 1, onChanged: n.setShortBreak),
          const SizedBox(height: 8),
          _DurationRow(label: 'Long break', icon: Icons.self_improvement_outlined, color: AppColors.longBreak,
              value: settings.longBreak, min: 5, max: 60, step: 5, onChanged: n.setLongBreak),
          const SizedBox(height: 8),
          _SettingCard(child: Row(children: [
            _IconBadge(icon: Icons.repeat_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sessions before long break', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${settings.sessionsBeforeLongBreak} pomodoros', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
            ])),
            _Stepper(
              value: settings.sessionsBeforeLongBreak,
              min: 2, max: 8,
              onDec: () => n.setFocusDuration(settings.focusDuration),
              onInc: () => n.setFocusDuration(settings.focusDuration),
              color: AppColors.accent,
            ),
          ])),

          const SizedBox(height: 20),
          _SectionLabel('Daily goal'),
          const SizedBox(height: 10),
          _SettingCard(child: Column(children: [
            Row(children: [
              _IconBadge(icon: Icons.flag_outlined, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Daily focus target', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${settings.dailyGoalMinutes} minutes per day', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
              ])),
            ]),
            const SizedBox(height: 12),
            Slider(
              value: settings.dailyGoalMinutes.toDouble(),
              min: 30, max: 300, divisions: 9,
              activeColor: AppColors.success,
              inactiveColor: AppColors.success.withOpacity(0.15),
              label: '${settings.dailyGoalMinutes}m',
              onChanged: (v) => n.setDailyGoal(v.round()),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('30m', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
              Text('${settings.dailyGoalMinutes}m', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
              Text('5h', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
            ]),
          ])),

          const SizedBox(height: 20),
          _SectionLabel('Preferences'),
          const SizedBox(height: 10),
          _SettingCard(child: Column(children: [
            _SwitchRow(icon: Icons.dark_mode_outlined, iconColor: const Color(0xFF7C3AED), label: 'Dark mode', subtitle: 'Easy on the eyes', value: settings.darkMode, onChanged: (_) => n.toggleDarkMode()),
            const Divider(height: 1),
            _SwitchRow(icon: Icons.volume_up_outlined, iconColor: AppColors.success, label: 'Sound effects', subtitle: 'Session completion sounds', value: settings.soundEnabled, onChanged: (_) => n.toggleSound()),
          ])),

          const SizedBox(height: 20),
          _SectionLabel('Quick links'),
          const SizedBox(height: 10),
          _SettingCard(child: Column(children: [
            _LinkRow(icon: Icons.emoji_events_outlined, color: AppColors.warning, label: 'Achievements', onTap: () => context.go('/achievements')),
            const Divider(height: 1),
            _LinkRow(icon: Icons.music_note_outlined, color: AppColors.info, label: 'Ambient sounds', onTap: () => context.go('/music')),
            const Divider(height: 1),
            _LinkRow(icon: Icons.checklist_rounded, color: AppColors.focus, label: 'My tasks', onTap: () => context.go('/tasks')),
          ])),

          const SizedBox(height: 20),
          _SectionLabel('About'),
          const SizedBox(height: 10),
          _SettingCard(child: Column(children: [
            _InfoRow(label: 'App', value: 'Regain v2.0'),
            const Divider(height: 1),
            _InfoRow(label: 'Version', value: '2.0.0'),
            const Divider(height: 1),
            _InfoRow(label: 'Built with', value: 'Flutter + Riverpod'),
          ])),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final StatsState stats;
  const _ProfileCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15)),
          child: Center(child: Text('⚡', style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Level ${stats.level}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('${stats.totalSessions} sessions · ${stats.currentStreak}-day streak', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.levelProgress, minHeight: 5,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ])),
        const SizedBox(width: 12),
        Text('${stats.xp}\nXP', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.2)),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)));
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
    child: child,
  );
}

class _DurationRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;
  const _DurationRow({required this.label, required this.icon, required this.color, required this.value, required this.min, required this.max, required this.step, required this.onChanged});

  @override
  Widget build(BuildContext context) => _SettingCard(child: Row(children: [
    _IconBadge(icon: icon, color: color),
    const SizedBox(width: 12),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    _Stepper(value: value, min: min, max: max, color: color, onDec: value > min ? () => onChanged(value - step) : null, onInc: value < max ? () => onChanged(value + step) : null),
  ]));
}

class _Stepper extends StatelessWidget {
  final int value, min, max;
  final Color color;
  final VoidCallback? onDec, onInc;
  const _Stepper({required this.value, required this.min, required this.max, required this.color, this.onDec, this.onInc});

  @override
  Widget build(BuildContext context) => Row(children: [
    _StepBtn(icon: Icons.remove, enabled: value > min, color: color, onTap: onDec),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${value}m', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color))),
    _StepBtn(icon: Icons.add, enabled: value < max, color: color, onTap: onInc),
  ]);
}

class _StepBtn extends StatelessWidget {
  final IconData icon; final bool enabled; final Color color; final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.enabled, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: enabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.06)),
      child: Icon(icon, size: 15, color: enabled ? color : Colors.grey.withOpacity(0.3))),
  );
}

class _IconBadge extends StatelessWidget {
  final IconData icon; final Color color;
  const _IconBadge({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color));
}

class _SwitchRow extends StatelessWidget {
  final IconData icon; final Color iconColor; final String label, subtitle; final bool value; final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.icon, required this.iconColor, required this.label, required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      _IconBadge(icon: icon, color: iconColor),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
      ])),
      Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    ]),
  );
}

class _LinkRow extends StatelessWidget {
  final IconData icon; final Color color; final String label; final VoidCallback onTap;
  const _LinkRow({required this.icon, required this.color, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        _IconBadge(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ]),
  );
}
