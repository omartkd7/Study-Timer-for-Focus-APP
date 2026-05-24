import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/shared/models/models.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';

final dailyGoalProvider = Provider<DailyGoal>((ref) {
  final stats = ref.watch(statsProvider);
  final settings = ref.watch(settingsProvider);
  return DailyGoal(
    targetMinutes: settings.dailyGoalMinutes,
    achievedMinutes: stats.todayMinutes,
    date: DateTime.now(),
  );
});
