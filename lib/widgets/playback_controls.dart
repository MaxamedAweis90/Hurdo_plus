import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/global_audio.dart';

class PlaybackControls extends StatefulWidget {
  const PlaybackControls({Key? key}) : super(key: key);

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  double _globalVolume = 0.7;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Read global audio controller if present
    final global = AppAudioScope.maybeOf(context);
    // Keep internal slider in sync if provided
    if (global != null && _globalVolume != global.volume) {
      _globalVolume = global.volume;
    }
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Global volume slider with icon
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: _globalVolume,
                          onChanged: (v) {
                            setState(() {
                              _globalVolume = v;
                            });
                            // propagate to global
                            global?.setVolume(v);
                          },
                          min: 0,
                          max: 1,
                          activeColor: scheme.primary,
                          inactiveColor: scheme.onSurface.withValues(
                            alpha: 0.24,
                          ),
                        ),
                      ),
                      Text(
                        '${(_globalVolume * 100).toInt()}%',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider between global volume and controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Divider(
                    color: scheme.onSurface.withValues(alpha: 0.18),
                    thickness: 1.1,
                    height: 18,
                  ),
                ),
                // Controls row
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                        onPressed: () {},
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.surface.withValues(alpha: 0.9),
                        ),
                        width: 56,
                        height: 56,
                        child: IconButton(
                          icon: Icon(
                            Icons.play_arrow_rounded,
                            color: scheme.primary,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.list_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.85),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
