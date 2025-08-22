import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/global_audio.dart';

class SoundCard extends StatefulWidget {
  final IconData icon;
  final double initialVolume;
  final Color? color; // When null, use theme colors
  final String? label;

  const SoundCard({
    super.key,
    this.icon = Icons.cloud,
    this.initialVolume = 0.7,
    this.color,
    this.label,
  });

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _stateSub;

  bool _isPlaying = false;
  double _volume = 0.7;

  // Demo sound URLs for each icon (rain, water, etc.)
  String get _demoUrl {
    if (widget.icon == Icons.cloud) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    } else if (widget.icon == Icons.water_drop) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
    } else if (widget.icon == Icons.bubble_chart) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3';
    } else if (widget.icon == Icons.nightlight_round) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3';
    } else if (widget.icon == Icons.forest) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3';
    } else if (widget.icon == Icons.bolt) {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3';
    }
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _volume = widget.initialVolume.clamp(0.0, 1.0);
    // Set initial volume
    // Will be combined with global in build
    _audioPlayer.setVolume(_volume);
    // Keep UI in sync with player
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }
      // Configure and start playback (looping)
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSourceUrl(_demoUrl);
      await _audioPlayer.resume();
    } catch (e) {
      // Swallow errors for demo; optionally show a SnackBar
      debugPrint('Audio error: $e');
    }
  }

  void _onVolumeChanged(double value) {
    setState(() => _volume = value);
    final global = AppAudioScope.maybeOf(context)?.volume ?? 1.0;
    _audioPlayer.setVolume(value * global);
  }

  @override
  Widget build(BuildContext context) {
    // react to global volume changes
    final global = AppAudioScope.maybeOf(context)?.volume ?? 1.0;
    // ensure player volume matches combined volume when building
    _audioPlayer.setVolume(_volume * global);
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final accent = widget.color ?? theme.colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: _togglePlay,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.label != null) ...[
                      Text(
                        widget.label!,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: 0.5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isPlaying ? accent : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (_isPlaying)
                            BoxShadow(
                              color: accent.withValues(alpha: 0.22),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      width: constraints.maxWidth * 0.38,
                      height: constraints.maxWidth * 0.38,
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: constraints.maxWidth * 0.16,
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.92,
                        ),
                        child: Icon(
                          widget.icon,
                          color: accent,
                          size: constraints.maxWidth * 0.18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 11,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                        activeTrackColor: accent,
                        inactiveTrackColor: accent.withValues(alpha: 0.18),
                        thumbColor: accent,
                        overlayColor: accent.withValues(alpha: 0.18),
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: _onVolumeChanged,
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
