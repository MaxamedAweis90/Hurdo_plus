import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withOpacity(0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.13),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

// --- Redesigned ProfileScreen and Theme Selector ---

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Glassmorphic User Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.13),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.07),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 22,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ricardo Joseph',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'ricardojoseph@gmail.com',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Removed edit icon for cleaner look
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // App Theme Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.99),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.color_lens_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'App Theme',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ThemeBubbleSelector(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // General Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.99),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'General',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ProfileTile(
                          icon: Icons.settings,
                          title: 'Profile Settings',
                          subtitle: 'Update and modify your profile',
                          onTap: () {},
                        ),
                        _ProfileTile(
                          icon: Icons.lock_outline,
                          title: 'Privacy',
                          subtitle: 'Change your password',
                          onTap: () {},
                        ),
                        _ProfileTile(
                          icon: Icons.notifications_none,
                          title: 'Notifications',
                          // ...existing code above...
                          // Removed duplicate/trailing widget tree after build method
                          subtitle: 'Change your notification settings',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeBubbleSelector extends ConsumerStatefulWidget {
  const _ThemeBubbleSelector();

  @override
  ConsumerState<_ThemeBubbleSelector> createState() =>
      _ThemeBubbleSelectorState();
}

class _ThemeBubbleSelectorState extends ConsumerState<_ThemeBubbleSelector> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = ref.read(themeIndexProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeList = appThemes;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < themeList.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _selectedIndex == i ? 38 : 32,
                            height: _selectedIndex == i ? 38 : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  themeList[i].primary,
                                  themeList[i].accent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                if (_selectedIndex == i)
                                  BoxShadow(
                                    color: themeList[i].accent.withOpacity(
                                      0.22,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                              border: Border.all(
                                color: _selectedIndex == i
                                    ? themeList[i].accent
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          if (_selectedIndex == i)
                            Icon(
                              Icons.circle_rounded,
                              color: themeList[i].onPrimary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: theme.colorScheme.primary,
          shape: const CircleBorder(),
          elevation: 2,
          child: IconButton(
            icon: Icon(
              Icons.check_rounded,
              color: theme.colorScheme.onPrimary,
              size: 22,
            ),
            splashRadius: 22,
            onPressed: () {
              ref.read(themeIndexProvider.notifier).state = _selectedIndex;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Theme applied!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ...existing _ProfileTile class remains unchanged...
