import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../widgets/hurdo_drawer.dart';

import 'home_screen.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  double _page = 0.0;

  final List<Widget> _screens = const [
    HomeScreen(key: ValueKey('home')),
    FavouritesScreen(key: ValueKey('favourites')),
    ProfileScreen(key: ValueKey('profile')),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _page = _selectedIndex.toDouble();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _page = _pageController.page ?? _selectedIndex.toDouble();
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        endDrawer: HurdoDrawer(
          onSelectTab: (int index) {
            _onItemTapped(index);
          },
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (_selectedIndex != index) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          children: _screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 70.0, right: 70.0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 70,
            borderRadius: 50,
            blur: 20,
            alignment: Alignment.bottomCenter,
            border: 2.2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.85),
                Theme.of(context).colorScheme.surface.withOpacity(0.65),
              ],
              stops: const [0.1, 1],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.18),
                Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ],
            ),
            child: SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sliding active icon background (decoupled from PageView)
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      final double x = (_page - 1) * 1.0;
                      return Align(
                        alignment: Alignment(x, 0),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.90),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Row of icons with animated color
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      final icons = [Icons.home, Icons.favorite, Icons.person];
                      final isActive = _selectedIndex == index;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child: TweenAnimationBuilder<Color?>(
                                tween: ColorTween(
                                  begin: isActive
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withOpacity(0.7)
                                      : Theme.of(context).colorScheme.onPrimary,
                                  end: isActive
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                                duration: const Duration(milliseconds: 350),
                                builder: (context, color, child) =>
                                    Icon(icons[index], color: color, size: 34),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
