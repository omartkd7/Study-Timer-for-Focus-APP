# Regain v2 — Study Timer for Focus

A complete Flutter Pomodoro productivity app with 5 new features added in v2.

## What's new in v2

| Feature | Description |
|---|---|
| 🌟 Splash screen | Animated logo ring + progress bar + motivational quote |
| 📋 Onboarding | 4-page swipeable intro with feature highlights |
| ✅ Task manager | Add, track, link tasks to timer sessions, swipe to delete |
| 🎵 Ambient sounds | 8 ambient tracks with volume control (Rain, Forest, Café…) |
| 🎯 Daily goals | Set & track daily focus target with a visual progress bar |
| 🏅 Achievements | 12 unlockable badges based on sessions, streaks, XP & level |

## Quick start

```bash
cd regain_v2
flutter pub get
flutter run
```

Runs on Android, iOS, Web & Desktop.

## App flow

```
Splash (2.5s) → Onboarding (first launch) → Timer
                                          ↓
                              ┌───────────────────────┐
                              │  Bottom nav (4 tabs)  │
                              │  Focus / Stats /      │
                              │  Ranks / Settings     │
                              └───────────────────────┘
                                    ↕  Full-screen routes
                              Tasks · Music · Achievements
```

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── router/app_router.dart
│   └── theme/app_theme.dart
├── shared/
│   ├── models/models.dart          ← Session, StudyTask, Achievement, AmbientTrack, DailyGoal
│   └── widgets/shell_scaffold.dart
└── features/
    ├── splash/        → SplashScreen
    ├── onboarding/    → OnboardingScreen (4 pages)
    ├── timer/         → TimerScreen + providers
    ├── stats/         → StatsScreen + StatsProvider
    ├── leaderboard/   → LeaderboardScreen
    ├── settings/      → SettingsScreen + SettingsProvider
    ├── tasks/         → TasksScreen + TasksProvider
    ├── music/         → MusicScreen + MusicProvider
    ├── goals/         → DailyGoalProvider (derived)
    └── achievements/  → AchievementsScreen + AchievementsProvider
```

## State management: Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `settingsProvider` | StateNotifier | App settings + SharedPreferences |
| `statsProvider` | StateNotifier | Sessions, XP, streak tracking |
| `timerProvider` | StateNotifier | Stopwatch-accurate Pomodoro engine |
| `tasksProvider` | StateNotifier | Study task CRUD |
| `musicProvider` | StateNotifier | Active track + play state + volume |
| `dailyGoalProvider` | Provider | Derived from stats + settings |
| `achievementsProvider` | Provider | Computed from stats in real-time |
| `leaderboardProvider` | Provider | Mock data (swap with Firestore) |

## Next steps (Phase 3+)

- [ ] Replace mock leaderboard with Firebase Firestore
- [ ] Add `firebase_auth` (Google Sign-In)
- [ ] Add `flutter_local_notifications` for break & streak reminders
- [ ] Add `isar` for faster local DB (replace SharedPreferences)
- [ ] Add `lottie` for level-up & achievement unlock animations
- [ ] Adaptive layout with `NavigationRail` for tablet/desktop
