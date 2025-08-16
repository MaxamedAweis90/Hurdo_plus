import 'package:flutter/material.dart';
import 'package:hurdo_plus/services/favourites_manager.dart';
import 'package:hurdo_plus/models/sound_model.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final FavouritesManager favouritesManager = FavouritesManager();

  @override
  void initState() {
    super.initState();
    favouritesManager.addListener(_onFavChanged);
  }

  @override
  void dispose() {
    favouritesManager.removeListener(_onFavChanged);
    super.dispose();
  }

  void _onFavChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favs = favouritesManager.favourites;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Title
            Text(
              'Favourites',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Two lines below title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Favourites grid
            Expanded(
              child: favs.isEmpty
                  ? Center(
                      child: Text(
                        'No favourites yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 18,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: favs.length,
                      itemBuilder: (context, index) {
                        final SoundModel sound = favs[index];
                        return Stack(
                          children: [
                            // Card
                            Center(
                              child: Container(
                                width: 150,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withOpacity(
                                        0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.music_note,
                                      size: 48,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      sound.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color:
                                                theme.colorScheme.onBackground,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Remove (X) button
                            Positioned(
                              top: 8,
                              right: 16,
                              child: GestureDetector(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Remove from favourites?',
                                      ),
                                      content: const Text(
                                        'Do you actually want to remove this sound from your favourites?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    favouritesManager.remove(sound);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
