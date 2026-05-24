import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/shared/models/models.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';

const _allAchievements = [
  Achievement(id: 'first_session',  emoji: '🎯', title: 'First step',      description: 'Complete your first session'),
  Achievement(id: 'session_10',     emoji: '🔟',  title: '10 sessions',     description: 'Complete 10 focus sessions'),
  Achievement(id: 'session_50',     emoji: '💯',  title: '50 sessions',     description: 'Complete 50 focus sessions'),
  Achievement(id: 'streak_3',       emoji: '🔥',  title: 'On fire',         description: 'Achieve a 3-day streak'),
  Achievement(id: 'streak_7',       emoji: '⚡',  title: 'Week warrior',    description: 'Achieve a 7-day streak'),
  Achievement(id: 'streak_30',      emoji: '🏆',  title: 'Month master',    description: 'Achieve a 30-day streak'),
  Achievement(id: 'hours_5',        emoji: '⏰',  title: '5 hour club',     description: 'Accumulate 5 hours of focus'),
  Achievement(id: 'hours_25',       emoji: '🌟',  title: '25 hour legend',  description: 'Accumulate 25 hours of focus'),
  Achievement(id: 'early_bird',     emoji: '🌅',  title: 'Early bird',      description: 'Start a session before 7 AM'),
  Achievement(id: 'night_owl',      emoji: '🦉',  title: 'Night owl',       description: 'Complete a session after 10 PM'),
  Achievement(id: 'level_5',        emoji: '💎',  title: 'Level 5',         description: 'Reach level 5'),
  Achievement(id: 'level_10',       emoji: '👑',  title: 'Level 10',        description: 'Reach level 10'),
];

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final stats = ref.watch(statsProvider);
  final hour = DateTime.now().hour;

  return _allAchievements.map((a) {
    bool unlocked = false;
    switch (a.id) {
      case 'first_session': unlocked = stats.totalSessions >= 1; break;
      case 'session_10':    unlocked = stats.totalSessions >= 10; break;
      case 'session_50':    unlocked = stats.totalSessions >= 50; break;
      case 'streak_3':      unlocked = stats.currentStreak >= 3; break;
      case 'streak_7':      unlocked = stats.currentStreak >= 7; break;
      case 'streak_30':     unlocked = stats.currentStreak >= 30; break;
      case 'hours_5':       unlocked = stats.totalMinutes >= 300; break;
      case 'hours_25':      unlocked = stats.totalMinutes >= 1500; break;
      case 'level_5':       unlocked = stats.level >= 5; break;
      case 'level_10':      unlocked = stats.level >= 10; break;
      case 'early_bird':    unlocked = hour < 7 && stats.totalSessions > 0; break;
      case 'night_owl':     unlocked = hour >= 22 && stats.totalSessions > 0; break;
    }
    return a.copyWith(unlocked: unlocked);
  }).toList();
});
