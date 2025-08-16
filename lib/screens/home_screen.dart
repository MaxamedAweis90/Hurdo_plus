import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
// import 'package:glassmorphism/glassmorphism.dart';
import 'package:hurdo_plus/services/audio_service_manager.dart';
// import 'package:hurdo_plus/models/sound_model.dart';
import 'package:hurdo_plus/services/favourites_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavouritesManager favouritesManager = FavouritesManager();
  // Use the global sounds list from audio_service_manager.dart directly
  int currentIndex = 0;
  bool isPlaying = false;
  bool isLoading = false;
  late PageController _pageController;
  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    // Listen to audio service playback state to keep UI in sync
    _playbackSub = AudioService.playbackStateStream.listen((state) {
      final playing = state.playing;
      if (mounted) {
        setState(() {
          isPlaying = playing;
        });
      }
    });

    // Listen to current media item changes (e.g., from notification controls)
    _mediaItemSub = AudioService.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem != null) {
        final idx = sounds.indexWhere((s) => s.url == mediaItem.id);
        if (idx != -1 && idx != currentIndex && mounted) {
          setState(() {
            currentIndex = idx;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(idx);
            }
          });
        }
      }
    });
  }

  Future<void> _playSound(int index) async {
    setState(() {
      isLoading = true;
    });
    try {
      await AudioManager().startService(sounds, index);
      setState(() {
        currentIndex = index;
        isPlaying = true;
      });
    } catch (e) {
      // Optionally show error
    } finally {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _playbackSub?.cancel();
    _mediaItemSub?.cancel();
    super.dispose();
  }

  void _onPlayPause() async {
    if (isLoading) return;
    if (isPlaying) {
      await AudioService.pause();
    } else {
      // If service not running, start with the current index and play
      if (!AudioService.running) {
        await _playSound(currentIndex);
      } else {
        await AudioService.play();
      }
    }
  }

  void _onShuffle() async {
    if (isLoading) return;
    int newIndex = currentIndex;
    while (newIndex == currentIndex) {
      newIndex =
          (sounds.length *
                  (DateTime.now().millisecondsSinceEpoch % 1000) /
                  1000)
              .floor();
    }
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await _playSound(newIndex);
  }

  void _onNext() async {
    if (isLoading) return;
    final next = (currentIndex + 1) % sounds.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await _playSound(next);
  }

  void _onPrev() async {
    if (isLoading) return;
    final prev = (currentIndex - 1 + sounds.length) % sounds.length;
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await _playSound(prev);
  }

  void _showAllSoundsPopup(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface.withOpacity(0.98),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 350,
            constraints: const BoxConstraints(maxHeight: 480),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'All Available Sounds',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 26),
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    itemCount: sounds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          if (currentIndex != index) {
                            await _playSound(index);
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(index);
                            }
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 90,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.13,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                image: sounds[index].artUri.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          sounds[index].artUri,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: sounds[index].artUri.isEmpty
                                  ? const Icon(
                                      Icons.music_note,
                                      color: Colors.blueGrey,
                                      size: 38,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sounds[index].title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ), // End of ListView.separated
                ), // End of Expanded
              ],
            ), // End of Column in Dialog
          ), // End of Container in Dialog
        ); // End of Dialog
      },
    ); // End of showDialog
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.15,
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Hurdo+',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.dehaze,
                      color: theme.colorScheme.onBackground,
                      size: 32,
                    ),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ],
              ),
            ),

            // PageView cards
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 380,
                  height: 480,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: sounds.length,
                    onPageChanged: (index) async {
                      if (currentIndex != index) {
                        await _playSound(index);
                      }
                    },
                    itemBuilder: (context, index) {
                      final s = sounds[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: s.artUri.isNotEmpty
                                    ? Image.network(s.artUri, fit: BoxFit.cover)
                                    : Container(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.08),
                                        child: const Center(
                                          child: Icon(
                                            Icons.music_note,
                                            size: 64,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (favouritesManager.isFavourite(s)) {
                                        favouritesManager.remove(s);
                                      } else {
                                        favouritesManager.add(s);
                                      }
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        favouritesManager.isFavourite(s)
                                        ? const Color(0xFFFFE5EA)
                                        : const Color(0xFF23242A),
                                    child: Icon(
                                      favouritesManager.isFavourite(s)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favouritesManager.isFavourite(s)
                                          ? const Color(0xFFFF6B81)
                                          : const Color(0xFFBFD6FF),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 24,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    s.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Container(
                  width: 340,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shuffle,
                          color: Color(0xFFBFD6FF),
                        ),
                        onPressed: isLoading ? null : _onShuffle,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFBFD6FF),
                        ),
                        onPressed: isLoading ? null : _onPrev,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2C2D34),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: const Color(0xFFBFD6FF),
                          ),
                          onPressed: isLoading ? null : _onPlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFBFD6FF),
                        ),
                        onPressed: isLoading ? null : _onNext,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.list_rounded,
                          color: Color(0xFFBFD6FF),
                        ),
                        onPressed: isLoading
                            ? null
                            : () => _showAllSoundsPopup(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
