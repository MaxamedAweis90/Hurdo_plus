import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hurdo_plus/models/sound_model.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  Future<void> startService(List<SoundModel> sounds, int startIndex) async {
    await AudioService.start(
      backgroundTaskEntrypoint: audioTaskEntrypoint,
      androidNotificationChannelName: 'Hurdo+ Audio',
      androidNotificationColor: 0xFF3A6FE8,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
      params: {
        'queue': sounds
            .map((s) => {'id': s.url, 'title': s.title, 'artUri': s.artUri})
            .toList(),
        'startIndex': startIndex,
      },
    );
  }

  static Future<void> audioTaskEntrypoint() async {
    AudioServiceBackground.run(() => AudioPlayerTask());
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _player = AudioPlayer();
  List<MediaItem> _queue = [];
  int _currentIndex = 0;

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // Build queue from params
    final queueParam = params?['queue'];
    final startIndex = params?['startIndex'] is int
        ? params!['startIndex'] as int
        : 0;
    if (queueParam is List) {
      _queue = queueParam.map<MediaItem>((dynamic item) {
        final Map<String, dynamic> map = item is Map
            ? Map<String, dynamic>.from(item)
            : {};
        final id = map['id']?.toString() ?? '';
        final title = map['title']?.toString() ?? 'Unknown';
        final art = map['artUri']?.toString();
        return MediaItem(
          id: id,
          title: title,
          artUri: (art != null && art.isNotEmpty) ? Uri.parse(art) : null,
          album: 'Hurdo+',
          artist: 'Hurdo+',
        );
      }).toList();
      AudioServiceBackground.setQueue(_queue);
      _currentIndex = startIndex;
      await _loadCurrent();
      AudioServiceBackground.setMediaItem(_queue[_currentIndex]);
    }
  }

  Future<void> _loadCurrent() async {
    if (_queue.isNotEmpty) {
      await _player.setUrl(_queue[_currentIndex].id);
    }
  }

  @override
  Future<void> onPlay() async {
    if (_player.audioSource == null && _queue.isNotEmpty) {
      await _loadCurrent();
    }
    await _player.play();
    AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      playing: _player.playing,
      processingState: AudioProcessingState.ready,
      position: _player.position,
    );
  }

  @override
  Future<void> onPause() async {
    await _player.pause();
    AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      playing: false,
      processingState: AudioProcessingState.ready,
      position: _player.position,
    );
  }

  @override
  Future<void> onSkipToNext() async {
    if (_queue.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _queue.length;
      await _loadCurrent();
      AudioServiceBackground.setMediaItem(_queue[_currentIndex]);
      await onPlay();
    }
  }

  @override
  Future<void> onSkipToPrevious() async {
    if (_queue.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
      await _loadCurrent();
      AudioServiceBackground.setMediaItem(_queue[_currentIndex]);
      await onPlay();
    }
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    await super.onStop();
  }
}

final List<SoundModel> sounds = [
  SoundModel(
    title: 'Rainy Night',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    artUri:
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  ),
  SoundModel(
    title: 'Calm Ocean',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    artUri:
        'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
  ),
  SoundModel(
    title: 'Forest Birds',
    url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    artUri:
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=400&q=80',
  ),
];
