// ── Timer enums ──────────────────────────────────────────────
enum TimerMode { focus, shortBreak, longBreak }
enum TimerStatus { idle, running, paused, finished }

extension TimerModeLabel on TimerMode {
  String get label {
    switch (this) {
      case TimerMode.focus:      return 'Focus';
      case TimerMode.shortBreak: return 'Short Break';
      case TimerMode.longBreak:  return 'Long Break';
    }
  }
}

// ── Session ───────────────────────────────────────────────────
class Session {
  final String id;
  final DateTime startTime;
  final int durationMinutes;
  final String subject;
  final bool completed;

  Session({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    required this.subject,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'subject': subject,
    'completed': completed,
  };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    id: j['id'],
    startTime: DateTime.parse(j['startTime']),
    durationMinutes: j['durationMinutes'],
    subject: j['subject'],
    completed: j['completed'],
  );
}

// ── Task ──────────────────────────────────────────────────────
class StudyTask {
  final String id;
  final String title;
  final String subject;
  final int estimatedPomodoros;
  int completedPomodoros;
  bool isDone;
  final DateTime createdAt;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.isDone = false,
    required this.createdAt,
  });

  StudyTask copyWith({
    String? title, String? subject,
    int? estimatedPomodoros, int? completedPomodoros,
    bool? isDone,
  }) => StudyTask(
    id: id, createdAt: createdAt,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
    completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'subject': subject,
    'estimatedPomodoros': estimatedPomodoros,
    'completedPomodoros': completedPomodoros,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudyTask.fromJson(Map<String, dynamic> j) => StudyTask(
    id: j['id'], title: j['title'], subject: j['subject'],
    estimatedPomodoros: j['estimatedPomodoros'],
    completedPomodoros: j['completedPomodoros'],
    isDone: j['isDone'],
    createdAt: DateTime.parse(j['createdAt']),
  );
}

// ── Achievement ───────────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) => Achievement(
    id: id, title: title, description: description, emoji: emoji,
    unlocked: unlocked ?? this.unlocked,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };
}

// ── Music track ───────────────────────────────────────────────
class AmbientTrack {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const AmbientTrack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}

// ── Goal ──────────────────────────────────────────────────────
class DailyGoal {
  final int targetMinutes;
  final int achievedMinutes;
  final DateTime date;

  const DailyGoal({
    required this.targetMinutes,
    required this.achievedMinutes,
    required this.date,
  });

  double get progress =>
      targetMinutes > 0 ? (achievedMinutes / targetMinutes).clamp(0, 1) : 0;
  bool get isAchieved => achievedMinutes >= targetMinutes;
}
