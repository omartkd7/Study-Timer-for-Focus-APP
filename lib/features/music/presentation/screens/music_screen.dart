import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/core/theme/app_theme.dart';
import 'package:regain/features/music/providers/music_provider.dart';

class MusicScreen extends ConsumerWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(musicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambient sounds'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.go('/timer')),
        actions: [
          if (music.isPlaying)
            TextButton.icon(
              onPressed: () => ref.read(musicProvider.notifier).stop(),
              icon: const Icon(Icons.stop_rounded, size: 16, color: AppColors.accent),
              label: const Text('Stop', style: TextStyle(color: AppColors.accent, fontSize: 13)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Now playing card
          if (music.isPlaying && music.activeTrackId != null) ...[
            _NowPlayingCard(music: music),
            const SizedBox(height: 20),
          ],
          // Volume
          _VolumeSlider(volume: music.volume, onChanged: (v) => ref.read(musicProvider.notifier).setVolume(v)),
          const SizedBox(height: 20),
          Text('Choose a sound', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
            ),
            itemCount: ambientTracks.length,
            itemBuilder: (_, i) {
              final track = ambientTracks[i];
              final isActive = music.activeTrackId == track.id;
              final isPlaying = isActive && music.isPlaying;
              return GestureDetector(
                onTap: () => ref.read(musicProvider.notifier).selectTrack(track.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.info.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isActive ? Border.all(color: AppColors.info.withValues(alpha: 0.5), width: 1.5) : null,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(track.emoji, style: const TextStyle(fontSize: 24)),
                      if (isActive && music.isLoading)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info))
                      else if (isPlaying)
                        const Icon(Icons.pause_rounded, size: 16, color: AppColors.info)
                      else if (isActive)
                        const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.info),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(track.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.info : null)),
                      Text(track.description, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                    ]),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
            ),
            child: const Row(children: [
              Icon(Icons.music_note_outlined, size: 16, color: AppColors.info),
              SizedBox(width: 10),
              Expanded(child: Text('Sounds are generated locally — no internet needed and fully copyright-free.', style: TextStyle(fontSize: 11, color: AppColors.info, height: 1.5))),
            ]),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final MusicState music;
  const _NowPlayingCard({required this.music});

  @override
  Widget build(BuildContext context) {
    final track = ambientTracks.firstWhere((t) => t.id == music.activeTrackId, orElse: () => ambientTracks.first);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Text(track.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Now playing', style: TextStyle(fontSize: 10, color: AppColors.info)),
          Text(track.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.info)),
          Text(track.description, style: TextStyle(fontSize: 11, color: AppColors.info.withValues(alpha: 0.7))),
        ])),
        // Animated bars indicator
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(3, (i) => _AnimBar(delay: i * 150))),
      ]),
    );
  }
}

class _AnimBar extends StatefulWidget {
  final int delay;
  const _AnimBar({required this.delay});
  @override
  State<_AnimBar> createState() => _AnimBarState();
}

class _AnimBarState extends State<_AnimBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 500 + widget.delay))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      margin: const EdgeInsets.only(left: 3),
      width: 3,
      height: 8 + _ctrl.value * 14,
      decoration: BoxDecoration(color: AppColors.info, borderRadius: BorderRadius.circular(2)),
    ),
  );
}

class _VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;
  const _VolumeSlider({required this.volume, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.volume_down_rounded, size: 20, color: AppColors.info),
        Expanded(child: Slider(
          value: volume, min: 0, max: 1,
          activeColor: AppColors.info,
          inactiveColor: AppColors.info.withValues(alpha: 0.15),
          onChanged: onChanged,
        )),
        const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.info),
        const SizedBox(width: 8),
        Text('${(volume * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.info)),
      ]),
    );
  }
}
