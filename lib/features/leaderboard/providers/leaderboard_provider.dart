import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int totalMinutes;
  final int streak;
  final int xp;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank, required this.name, required this.avatar,
    required this.totalMinutes, required this.streak, required this.xp,
    this.isCurrentUser = false,
  });

  String get formattedHours {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return h == 0 ? '${m}m' : '${h}h ${m}m';
  }
}

final leaderboardProvider = Provider<List<LeaderboardEntry>>((_) => const [
  LeaderboardEntry(rank:1, name:'Layla K.',   avatar:'🏆', totalMinutes:2340, streak:21, xp:4200),
  LeaderboardEntry(rank:2, name:'Omar S.',    avatar:'🔥', totalMinutes:2100, streak:15, xp:3800),
  LeaderboardEntry(rank:3, name:'Sara M.',    avatar:'⚡', totalMinutes:1980, streak:12, xp:3600),
  LeaderboardEntry(rank:4, name:'Youssef A.', avatar:'🎯', totalMinutes:1800, streak:10, xp:3200),
  LeaderboardEntry(rank:5, name:'You',        avatar:'🌟', totalMinutes:1620, streak:7,  xp:240,  isCurrentUser:true),
  LeaderboardEntry(rank:6, name:'Khalid B.',  avatar:'💡', totalMinutes:1500, streak:7,  xp:2700),
  LeaderboardEntry(rank:7, name:'Amira T.',   avatar:'🚀', totalMinutes:1380, streak:6,  xp:2500),
  LeaderboardEntry(rank:8, name:'Hassan Z.',  avatar:'🎓', totalMinutes:1200, streak:5,  xp:2200),
]);
