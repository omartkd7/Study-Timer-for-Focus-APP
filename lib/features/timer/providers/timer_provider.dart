import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/shared/models/models.dart';
import 'package:regain/core/constants/app_constants.dart';
import 'package:regain/features/settings/providers/settings_provider.dart';
import 'package:regain/features/stats/providers/stats_provider.dart';
import 'package:regain/features/tasks/providers/tasks_provider.dart';

class TimerState {
  final TimerMode mode;
  final TimerStatus status;
  final int totalSeconds;
  final int remainingSeconds;
  final int completedSessions;
  final String subject;
  final String? activeTaskId;

  const TimerState({
    this.mode = TimerMode.focus,
    this.status = TimerStatus.idle,
    this.totalSeconds = AppConstants.defaultFocusDuration * 60,
    this.remainingSeconds = AppConstants.defaultFocusDuration * 60,
    this.completedSessions = 0,
    this.subject = 'Study',
    this.activeTaskId,
  });

  double get progress => totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  TimerState copyWith({
    TimerMode? mode, TimerStatus? status,
    int? totalSeconds, int? remainingSeconds,
    int? completedSessions, String? subject, String? activeTaskId,
    bool clearTask = false,
  }) => TimerState(
    mode: mode ?? this.mode,
    status: status ?? this.status,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    completedSessions: completedSessions ?? this.completedSessions,
    subject: subject ?? this.subject,
    activeTaskId: clearTask ? null : activeTaskId ?? this.activeTaskId,
  );
}

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _ticker;
  Stopwatch _sw = Stopwatch();
  int _baseRemaining = 0;

  TimerNotifier(this._ref) : super(const TimerState()) {
    _initFromSettings();
  }

  void _initFromSettings() {
    final s = _ref.read(settingsProvider);
    final secs = s.focusDuration * 60;
    state = state.copyWith(totalSeconds: secs, remainingSeconds: secs);
  }

  void start() {
    if (state.status == TimerStatus.running) return;
    _baseRemaining = state.remainingSeconds;
    _sw = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    state = state.copyWith(status: TimerStatus.running);
  }

  void pause() {
    _ticker?.cancel(); _sw.stop();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resume() => start();

  void skip() {
    _ticker?.cancel(); _sw.stop();
    _advanceMode();
  }

  void reset() {
    _ticker?.cancel(); _sw.stop();
    final s = _ref.read(settingsProvider);
    final secs = _durationFor(state.mode, s) * 60;
    state = state.copyWith(status: TimerStatus.idle, totalSeconds: secs, remainingSeconds: secs);
  }

  void setSubject(String subject) => state = state.copyWith(subject: subject);

  void setActiveTask(String taskId, String subject) =>
      state = state.copyWith(activeTaskId: taskId, subject: subject);

  void clearTask() => state = state.copyWith(clearTask: true);

  void _tick() {
    final elapsed = _sw.elapsed.inSeconds;
    final remaining = (_baseRemaining - elapsed).clamp(0, _baseRemaining);
    if (remaining <= 0) {
      _ticker?.cancel(); _sw.stop();
      _onComplete();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  void _onComplete() {
    if (state.mode == TimerMode.focus) {
      final settings = _ref.read(settingsProvider);
      final newCount = state.completedSessions + 1;
      _ref.read(statsProvider.notifier).recordSession(
        durationMinutes: settings.focusDuration,
        subject: state.subject,
      );
      if (state.activeTaskId != null) {
        _ref.read(tasksProvider.notifier).incrementPomodoro(state.activeTaskId!);
      }
      state = state.copyWith(
        status: TimerStatus.finished,
        completedSessions: newCount,
        remainingSeconds: 0,
      );
    } else {
      state = state.copyWith(status: TimerStatus.finished, remainingSeconds: 0);
    }
    Future.delayed(const Duration(seconds: 1), _advanceMode);
  }

  void _advanceMode() {
    final settings = _ref.read(settingsProvider);
    TimerMode next;
    if (state.mode == TimerMode.focus) {
      next = state.completedSessions % settings.sessionsBeforeLongBreak == 0
          ? TimerMode.longBreak
          : TimerMode.shortBreak;
    } else {
      next = TimerMode.focus;
    }
    final secs = _durationFor(next, settings) * 60;
    state = state.copyWith(mode: next, status: TimerStatus.idle, totalSeconds: secs, remainingSeconds: secs);
  }

  int _durationFor(TimerMode m, SettingsState s) {
    switch (m) {
      case TimerMode.focus:      return s.focusDuration;
      case TimerMode.shortBreak: return s.shortBreak;
      case TimerMode.longBreak:  return s.longBreak;
    }
  }

  @override
  void dispose() { _ticker?.cancel(); super.dispose(); }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier(ref));
