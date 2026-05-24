import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/leaderboard/providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(leaderboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Weekly'), Tab(text: 'All time')],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _LeaderboardList(entries: entries),
          _LeaderboardList(entries: entries.reversed.toList()),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _LeaderboardList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (entries.length >= 3) _Podium(top3: entries.take(3).toList()),
        const SizedBox(height: 16),
        ...entries.skip(3).map((e) => _RankRow(entry: e)),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  const _Podium({required this.top3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _PodiumCol(entry: top3[1], height: 130, color: const Color(0xFF9AA0A6))),
        Expanded(child: _PodiumCol(entry: top3[0], height: 170, color: const Color(0xFFFFD700), crown: true)),
        Expanded(child: _PodiumCol(entry: top3[2], height: 110, color: const Color(0xFFCD7F32))),
      ]),
    );
  }
}

class _PodiumCol extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color color;
  final bool crown;
  const _PodiumCol({required this.entry, required this.height, required this.color, this.crown = false});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      if (crown) const Text('👑', style: TextStyle(fontSize: 18)),
      Text(entry.avatar, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 3),
      Text(entry.name.split(' ').first, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text(entry.formattedHours, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(child: Text('#${entry.rank}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color))),
      ),
    ]);
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isCurrentUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppColors.primary.withValues(alpha: 0.4)) : null,
      ),
      child: Row(children: [
        SizedBox(width: 30, child: Text('#${entry.rank}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isMe ? AppColors.primary : Colors.grey))),
        const SizedBox(width: 6),
        Text(entry.avatar, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.name + (isMe ? ' (You)' : ''), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isMe ? AppColors.primary : null)),
          Text('🔥 ${entry.streak}-day streak', style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.6))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(entry.formattedHours, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isMe ? AppColors.primary : null)),
          Text('${entry.xp} XP', style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.5))),
        ]),
      ]),
    );
  }
}
