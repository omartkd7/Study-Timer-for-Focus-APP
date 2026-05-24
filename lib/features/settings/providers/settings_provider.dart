import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regain/core/constants/app_constants.dart';

class SettingsState {
  final int focusDuration;
  final int shortBreak;
  final int longBreak;
  final int sessionsBeforeLongBreak;
  final bool darkMode;
  final bool soundEnabled;
  final bool onboardingDone;
  final int dailyGoalMinutes;

  const SettingsState({
    this.focusDuration = AppConstants.defaultFocusDuration,
    this.shortBreak = AppConstants.defaultShortBreak,
    this.longBreak = AppConstants.defaultLongBreak,
    this.sessionsBeforeLongBreak = AppConstants.defaultSessionsBeforeLongBreak,
    this.darkMode = true,
    this.soundEnabled = true,
    this.onboardingDone = false,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
  });

  SettingsState copyWith({
    int? focusDuration, int? shortBreak, int? longBreak,
    int? sessionsBeforeLongBreak, bool? darkMode, bool? soundEnabled,
    bool? onboardingDone, int? dailyGoalMinutes,
  }) => SettingsState(
    focusDuration: focusDuration ?? this.focusDuration,
    shortBreak: shortBreak ?? this.shortBreak,
    longBreak: longBreak ?? this.longBreak,
    sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
    darkMode: darkMode ?? this.darkMode,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = SettingsState(
      focusDuration: p.getInt(AppConstants.keyFocusDuration) ?? AppConstants.defaultFocusDuration,
      shortBreak: p.getInt(AppConstants.keyShortBreak) ?? AppConstants.defaultShortBreak,
      longBreak: p.getInt(AppConstants.keyLongBreak) ?? AppConstants.defaultLongBreak,
      sessionsBeforeLongBreak: p.getInt(AppConstants.keySessionsBeforeLong) ?? AppConstants.defaultSessionsBeforeLongBreak,
      darkMode: p.getBool(AppConstants.keyDarkMode) ?? true,
      soundEnabled: p.getBool(AppConstants.keySoundEnabled) ?? true,
      onboardingDone: p.getBool(AppConstants.keyOnboardingDone) ?? false,
      dailyGoalMinutes: p.getInt(AppConstants.keyDailyGoalMinutes) ?? AppConstants.defaultDailyGoalMinutes,
    );
  }

  Future<void> _set(Future<void> Function(SharedPreferences) fn) async {
    final p = await SharedPreferences.getInstance();
    await fn(p);
  }

  Future<void> setFocusDuration(int v) async { await _set((p) => p.setInt(AppConstants.keyFocusDuration, v)); state = state.copyWith(focusDuration: v); }
  Future<void> setShortBreak(int v) async { await _set((p) => p.setInt(AppConstants.keyShortBreak, v)); state = state.copyWith(shortBreak: v); }
  Future<void> setLongBreak(int v) async { await _set((p) => p.setInt(AppConstants.keyLongBreak, v)); state = state.copyWith(longBreak: v); }
  Future<void> setDailyGoal(int v) async { await _set((p) => p.setInt(AppConstants.keyDailyGoalMinutes, v)); state = state.copyWith(dailyGoalMinutes: v); }
  Future<void> toggleDarkMode() async { final n = !state.darkMode; await _set((p) => p.setBool(AppConstants.keyDarkMode, n)); state = state.copyWith(darkMode: n); }
  Future<void> toggleSound() async { final n = !state.soundEnabled; await _set((p) => p.setBool(AppConstants.keySoundEnabled, n)); state = state.copyWith(soundEnabled: n); }
  Future<void> completeOnboarding() async { await _set((p) => p.setBool(AppConstants.keyOnboardingDone, true)); state = state.copyWith(onboardingDone: true); }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((_) => SettingsNotifier());
