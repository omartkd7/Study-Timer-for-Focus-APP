import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

// ── Free ambient sounds (orangefreesounds.com) ───────────────────────────────
// Files are free for personal/non-commercial use.
// Procedural fallback is used when offline or URL is unavailable.
const _trackUrls = <String, String>{
  'rain':    'https://www.orangefreesounds.com/wp-content/uploads/2016/05/Rain-sounds-and-bird-song-for-healing.mp3',
  'forest':  'https://www.orangefreesounds.com/wp-content/uploads/2017/09/Forest-ambience.mp3',
  'cafe':    'https://www.orangefreesounds.com/wp-content/uploads/2020/02/Coffee-shop-background-noise.mp3',
  'ocean':   'https://orangefreesounds.com/wp-content/uploads/2022/07/Ocean-waves-sound-effect.mp3',
  'fire':    'https://orangefreesounds.com/wp-content/uploads/2023/05/Fireplace-and-rain-sounds.mp3',
  'space':   'https://orangefreesounds.com/wp-content/uploads/2025/03/Cosmic-ambient-soundscape-music.mp3',
  'library': 'https://www.orangefreesounds.com/wp-content/uploads/2016/04/Rainforest-sounds.mp3',
  'thunder': 'https://orangefreesounds.com/wp-content/uploads/2022/06/Thunderstorm-ambience.mp3',
};

// ── Procedural fallback (offline) ────────────────────────────────────────────
enum _NoiseColor { brown, pink, white, ocean, fire, space, library, thunder }

_NoiseColor _noiseFor(String id) {
  switch (id) {
    case 'rain':      return _NoiseColor.brown;
    case 'forest':    return _NoiseColor.pink;
    case 'cafe':      return _NoiseColor.white;
    case 'ocean':     return _NoiseColor.ocean;
    case 'fire':      return _NoiseColor.fire;
    case 'space':     return _NoiseColor.space;
    case 'library':   return _NoiseColor.library;
    case 'thunder':   return _NoiseColor.thunder;
    default:          return _NoiseColor.brown;
  }
}

Uint8List generateNoiseWav(int colorIndex) {
  const sr = 22050, sec = 10, n = sr * sec;
  const ds = n * 2, fs = 44 + ds;
  final buf = Uint8List(fs);
  final bd  = buf.buffer.asByteData();
  buf[0]=0x52;buf[1]=0x49;buf[2]=0x46;buf[3]=0x46;
  bd.setUint32(4, fs-8, Endian.little);
  buf[8]=0x57;buf[9]=0x41;buf[10]=0x56;buf[11]=0x45;
  buf[12]=0x66;buf[13]=0x6D;buf[14]=0x74;buf[15]=0x20;
  bd.setUint32(16,16,Endian.little);bd.setUint16(20,1,Endian.little);
  bd.setUint16(22,1,Endian.little);bd.setUint32(24,sr,Endian.little);
  bd.setUint32(28,sr*2,Endian.little);bd.setUint16(32,2,Endian.little);
  bd.setUint16(34,16,Endian.little);
  buf[36]=0x64;buf[37]=0x61;buf[38]=0x74;buf[39]=0x61;
  bd.setUint32(40, ds, Endian.little);
  final c=_NoiseColor.values[colorIndex],rng=Random(colorIndex+7);
  double bw=0,b0=0,b1=0,b2=0,b3=0,b4=0,b5=0,b6=0;
  for(int i=0;i<n;i++){
    final w=rng.nextDouble()*2-1; double s;
    switch(c){
      case _NoiseColor.brown: bw=(bw+w*0.02).clamp(-1.0,1.0);s=bw*3.2;
      case _NoiseColor.pink:
        b0=0.99886*b0+w*0.0555179;b1=0.99332*b1+w*0.0750759;
        b2=0.96900*b2+w*0.1538520;b3=0.86650*b3+w*0.3104856;
        b4=0.55000*b4+w*0.5329522;b5=-0.7616*b5-w*0.0168980;
        s=(b0+b1+b2+b3+b4+b5+b6+w*0.5362)/9.0;b6=w*0.115926;
      case _NoiseColor.white: s=w*0.28;
      case _NoiseColor.ocean:
        bw=(bw+w*0.015).clamp(-1.0,1.0);
        s=bw*2.8*(0.5+0.5*sin(i*2*pi/(sr*3.2)));
      case _NoiseColor.fire:
        bw=(bw+w*0.02).clamp(-1.0,1.0);
        s=bw*2.2+(rng.nextDouble()>0.997?w*0.9:0.0);
      case _NoiseColor.space:
        s=sin(i*2*pi*55/sr)*0.32+sin(i*2*pi*27.5/sr)*0.22+w*0.018;
      case _NoiseColor.library:
        b0=0.99886*b0+w*0.0555179;b1=0.99332*b1+w*0.0750759;
        s=(b0+b1+w*0.3)/14.0;
      case _NoiseColor.thunder:
        bw=(bw+w*0.025).clamp(-1.0,1.0);
        final bp=(i%(sr*5))/(sr*0.8);
        s=bw*2.5*(bp<1.0?sin(bp*pi)*1.4:1.0);
    }
    bd.setInt16(44+i*2,(s.clamp(-0.95,0.95)*32767).round(),Endian.little);
  }
  return buf;
}

// StreamAudioSource for the fallback WAV bytes
class _WavBytesSource extends StreamAudioSource {
  final Uint8List _b;
  _WavBytesSource(this._b);
  @override
  Future<StreamAudioResponse> request([int? start,int? end]) async {
    start??=0; end??=_b.length;
    return StreamAudioResponse(
      sourceLength:_b.length, contentLength:end-start, offset:start,
      stream:Stream.value(Uint8List.view(_b.buffer,start,end-start)),
      contentType:'audio/wav',
    );
  }
}

// ── AudioService ─────────────────────────────────────────────────────────────
class AudioService {
  static final AudioService _i = AudioService._();
  factory AudioService() => _i;
  AudioService._();

  AudioPlayer? _player;
  final Map<String,Uint8List> _noiseCache = {};

  Future<void> play(String trackId, double volume) async {
    await stop();
    _player = AudioPlayer();
    await _player!.setVolume(volume.clamp(0.0, 1.0));
    await _player!.setLoopMode(LoopMode.one);

    final url = _trackUrls[trackId];
    bool loaded = false;

    if (url != null) {
      try {
        await _player!.setUrl(url);
        loaded = true;
      } catch (_) {
        // URL unavailable — fall through to procedural fallback
      }
    }

    if (!loaded) {
      final bytes = _noiseCache[trackId] ??= await compute(
        generateNoiseWav,
        _noiseFor(trackId).index,
      );
      await _player!.setAudioSource(_WavBytesSource(bytes));
    }

    await _player!.play();
  }

  Future<void> pause()  async => _player?.pause();
  Future<void> resume() async => _player?.play();

  Future<void> setVolume(double v) async =>
      _player?.setVolume(v.clamp(0.0, 1.0));

  Future<void> stop() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }
}