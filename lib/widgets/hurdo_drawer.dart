import 'package:flutter/material.dart';

class HurdoDrawer extends StatelessWidget {
  const HurdoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withOpacity(
                      0.12,
                    ),
                    child: Icon(
                      Icons.nightlight_round,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hurdo+',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Relax, Sleep, Enjoy',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.library_music_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('All Sounds'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.favorite_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Favourites'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.star_border,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Rate Us'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Share App'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.feedback_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Send Feedback'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.apps_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Other Apps'),
              onTap: () {},
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent_outlined),
                    label: const Text('Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('Support Developer'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
