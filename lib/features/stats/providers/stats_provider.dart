import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regain/core/constants/app_constants.dart';
import 'package:regain/shared/models/models.dart';

class StatsState {
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int xp;
  final List<Session> sessions;
  final Map<String, int> dailyMinutes;

  const StatsState({
    this.totalSessions = 0, this.totalMinutes = 0,
    this.currentStreak = 0, this.xp = 0,
    this.sessions = const [], this.dailyMinutes = const {},
  });

  int get level => (xp / 100).floor() + 1;
  int get xpInCurrentLevel => xp % 100;
  double get levelProgress => xpInCurrentLevel / 100;

  String get todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
  int get todayMinutes => dailyMinutes[todayKey] ?? 0;

  StatsState copyWith({
    int? totalSessions, int? totalMinutes, int? currentStreak,
    int? xp, List<Session>? sessions, Map<String, int>? dailyMinutes,
  }) => StatsState(
    totalSessions: totalSessions ?? this.totalSessions,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    currentStreak: currentStreak ?? this.currentStreak,
    xp: xp ?? this.xp,
    sessions: sessions ?? this.sessions,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
  );
}

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier() : super(const StatsState()) { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final sj = p.getStringList('sessions') ?? [];
    final sessions = sj.map((s) => Session.fromJson(jsonDecode(s))).toList()
      ..sort((a,b) => b.startTime.compareTo(a.startTime));
    final dj = p.getString('daily_minutes');
    final daily = dj != null ? Map<String,int>.from(jsonDecode(dj)) : <String,int>{};
    state = state.copyWith(
      totalSessions: p.getInt(AppConstants.keyTotalSessions) ?? 0,
      totalMinutes: p.getInt(AppConstants.keyTotalMinutes) ?? 0,
      currentStreak: p.getInt(AppConstants.keyCurrentStreak) ?? 0,
      xp: p.getInt(AppConstants.keyXp) ?? 0,
      sessions: sessions, dailyMinutes: daily,
    );
  }

  Future<void> recordSession({required int durationMinutes, required String subject}) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dk = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    final session = Session(
      id: now.millisecondsSinceEpoch.toString(),
      startTime: now, durationMinutes: durationMinutes,
      subject: subject, completed: true,
    );
    final updatedSessions = [session, ...state.sessions];
    final updatedDaily = Map<String,int>.from(state.dailyMinutes);
    updatedDaily[dk] = (updatedDaily[dk] ?? 0) + durationMinutes;
    final earnedXp = durationMinutes * AppConstants.xpPerFocusMinute + AppConstants.xpPerCompletedSession;
    final newXp = state.xp + earnedXp;
    final lastStr = p.getString(AppConstants.keyLastSessionDate);
    int newStreak = state.currentStreak;
    if (lastStr == null) {
      newStreak = 1;
    } else {
      final last = DateTime.parse(lastStr);
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) { newStreak++; }
      else if (diff > 1) { newStreak = 1; }
    }
    final newTotal = state.totalSessions + 1;
    final newMins = state.totalMinutes + durationMinutes;
    await p.setStringList('sessions', updatedSessions.map((s) => jsonEncode(s.toJson())).toList());
    await p.setString('daily_minutes', jsonEncode(updatedDaily));
    await p.setInt(AppConstants.keyTotalSessions, newTotal);
    await p.setInt(AppConstants.keyTotalMinutes, newMins);
    await p.setInt(AppConstants.keyCurrentStreak, newStreak);
    await p.setInt(AppConstants.keyXp, newXp);
    await p.setString(AppConstants.keyLastSessionDate, now.toIso8601String());
    state = state.copyWith(
      totalSessions: newTotal, totalMinutes: newMins,
      currentStreak: newStreak, xp: newXp,
      sessions: updatedSessions, dailyMinutes: updatedDaily,
    );
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((_) => StatsNotifier());
