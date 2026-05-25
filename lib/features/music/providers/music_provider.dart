import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/shared/models/models.dart';
import 'package:regain/services/audio_service.dart';

const ambientTracks = [
  AmbientTrack(id: 'rain',    name: 'Rain',         emoji: '🌧️', description: 'Gentle rainfall'),
  AmbientTrack(id: 'forest',  name: 'Forest',       emoji: '🌲', description: 'Birds & wind'),
  AmbientTrack(id: 'cafe',    name: 'Coffee shop',  emoji: '☕', description: 'Ambient chatter'),
  AmbientTrack(id: 'ocean',   name: 'Ocean waves',  emoji: '🌊', description: 'Calming waves'),
  AmbientTrack(id: 'fire',    name: 'Fireplace',    emoji: '🔥', description: 'Crackling fire'),
  AmbientTrack(id: 'space',   name: 'Deep space',   emoji: '🚀', description: 'Cosmic drone'),
  AmbientTrack(id: 'library', name: 'Library',      emoji: '📚', description: 'Quiet ambience'),
  AmbientTrack(id: 'thunder', name: 'Thunderstorm', emoji: '⛈️', description: 'Thunder & rain'),
];

class MusicState {
  final String? activeTrackId;
  final bool isPlaying;
  final bool isLoading;
  final double volume;

  const MusicState({
    this.activeTrackId,
    this.isPlaying = false,
    this.isLoading = false,
    this.volume = 0.7,
  });

  MusicState copyWith({
    String? activeTrackId,
    bool? isPlaying,
    bool? isLoading,
    double? volume,
    bool clearTrack = false,
  }) => MusicState(
    activeTrackId: clearTrack ? null : activeTrackId ?? this.activeTrackId,
    isPlaying:  isPlaying  ?? this.isPlaying,
    isLoading:  isLoading  ?? this.isLoading,
    volume:     volume     ?? this.volume,
  );
}

class MusicNotifier extends StateNotifier<MusicState> {
  MusicNotifier() : super(const MusicState());

  final _audio = AudioService();

  Future<void> selectTrack(String id) async {
    // Tap same track → toggle play/pause
    if (state.activeTrackId == id) {
      if (state.isPlaying) {
        await _audio.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        await _audio.resume();
        state = state.copyWith(isPlaying: true);
      }
      return;
    }

    // New track — show loading, generate noise, then play
    state = state.copyWith(activeTrackId: id, isPlaying: false, isLoading: true);
    await _audio.play(id, state.volume);
    state = state.copyWith(isPlaying: true, isLoading: false);
  }

  Future<void> stop() async {
    await _audio.stop();
    state = state.copyWith(isPlaying: false, isLoading: false, clearTrack: true);
  }

  Future<void> setVolume(double v) async {
    await _audio.setVolume(v);
    state = state.copyWith(volume: v);
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>(
  (_) => MusicNotifier(),
);