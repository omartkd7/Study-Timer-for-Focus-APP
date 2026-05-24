class AppConstants {
  // Pomodoro defaults
  static const defaultFocusDuration = 25;
  static const defaultShortBreak = 5;
  static const defaultLongBreak = 15;
  static const defaultSessionsBeforeLongBreak = 4;

  // XP system
  static const xpPerFocusMinute = 2;
  static const xpPerCompletedSession = 10;
  static const xpStreakBonus = 5;

  // SharedPreferences keys
  static const keyFocusDuration = 'focus_duration';
  static const keyShortBreak = 'short_break';
  static const keyLongBreak = 'long_break';
  static const keySessionsBeforeLong = 'sessions_before_long';
  static const keyDarkMode = 'dark_mode';
  static const keySoundEnabled = 'sound_enabled';
  static const keyTotalSessions = 'total_sessions';
  static const keyTotalMinutes = 'total_minutes';
  static const keyCurrentStreak = 'current_streak';
  static const keyXp = 'xp';
  static const keyLastSessionDate = 'last_session_date';
  static const keyOnboardingDone = 'onboarding_done';
  static const keyDailyGoalMinutes = 'daily_goal_minutes';
  static const keyTasks = 'tasks';
  static const keyAchievements = 'achievements';

  // Daily goal defaults
  static const defaultDailyGoalMinutes = 120;

  // Motivational quotes for splash
  static const quotes = [
    'Reclaim your focus, one session at a time.',
    'Small steps every day lead to big results.',
    'Your future self will thank you.',
    'Progress over perfection.',
    'Every expert was once a beginner.',
  ];
}
