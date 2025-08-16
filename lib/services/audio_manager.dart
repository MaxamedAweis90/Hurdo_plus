import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Future<void> startService() async {
    if (!AudioService.running) {
      await AudioService.start(
        backgroundTaskEntrypoint: _audioTaskEntrypoint,
        androidNotificationChannelName: 'Hurdo+ Audio',
        androidNotificationColor: 0xFF3A6FE8,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
      );
    }
  }

  static Future<void> _audioTaskEntrypoint() async {
    AudioServiceBackground.run(() => AudioPlayerTask());
  }

  Future<void> play() async {
    await startService();
    await AudioService.play();
  }

  Future<void> pause() async {
    await AudioService.pause();
  }

  Future<void> stop() async {
    await AudioService.stop();
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _player = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // Optionally preload or set up audio here
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onStop() async {
    await _player.stop();
    await super.onStop();
  }
}
