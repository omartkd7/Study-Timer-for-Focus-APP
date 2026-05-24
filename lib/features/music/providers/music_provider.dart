import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regain/shared/models/models.dart';

const ambientTracks = [
  AmbientTrack(id: 'rain',      name: 'Rain',         emoji: '🌧️', description: 'Gentle rainfall'),
  AmbientTrack(id: 'forest',    name: 'Forest',       emoji: '🌲', description: 'Birds & wind'),
  AmbientTrack(id: 'cafe',      name: 'Coffee shop',  emoji: '☕', description: 'Ambient chatter'),
  AmbientTrack(id: 'ocean',     name: 'Ocean waves',  emoji: '🌊', description: 'Calming waves'),
  AmbientTrack(id: 'fire',      name: 'Fireplace',    emoji: '🔥', description: 'Crackling fire'),
  AmbientTrack(id: 'space',     name: 'Deep space',   emoji: '🚀', description: 'Cosmic silence'),
  AmbientTrack(id: 'library',   name: 'Library',      emoji: '📚', description: 'Soft page turns'),
  AmbientTrack(id: 'thunder',   name: 'Thunderstorm', emoji: '⛈️', description: 'Thunder & rain'),
];

class MusicState {
  final String? activeTrackId;
  final bool isPlaying;
  final double volume;

  const MusicState({this.activeTrackId, this.isPlaying = false, this.volume = 0.7});

  MusicState copyWith({String? activeTrackId, bool? isPlaying, double? volume, bool clearTrack = false}) =>
      MusicState(
        activeTrackId: clearTrack ? null : activeTrackId ?? this.activeTrackId,
        isPlaying: isPlaying ?? this.isPlaying,
        volume: volume ?? this.volume,
      );
}

class MusicNotifier extends StateNotifier<MusicState> {
  MusicNotifier() : super(const MusicState());

  void selectTrack(String id) {
    if (state.activeTrackId == id) {
      state = state.copyWith(isPlaying: !state.isPlaying);
    } else {
      state = state.copyWith(activeTrackId: id, isPlaying: true);
    }
  }

  void stop() => state = state.copyWith(isPlaying: false, clearTrack: true);

  void setVolume(double v) => state = state.copyWith(volume: v);
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((_) => MusicNotifier());
