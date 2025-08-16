import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  final List<_OnboardingCardData> _cards = const [
    _OnboardingCardData(
      title: 'Relaxing Rain',
      description: 'Enjoy soothing rain sounds for relaxation and sleep.',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    ),
    _OnboardingCardData(
      title: 'Save Your Favorites',
      description: 'Bookmark your favorite sounds for quick access.',
      imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
    ),
    _OnboardingCardData(
      title: 'Cross-Device Login',
      description: 'Sync your sounds and favorites across devices.',
      imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
    ),
  ];

  String get buttonText {
    if (_step == 0) return 'Next';
    if (_step == 1) return 'Start';
    return 'Start';
  }

  Future<void> _onButtonPressed() async {
    if (_step < 2) {
      setState(() {
        _step++;
      });
    } else {
      // Set onboarding complete flag and navigate to main shell
      // Uncomment and adjust imports as needed
      // await LocalStorageService.setOnboardingComplete();
      // if (context.mounted) {
      //   Navigator.of(context).pushReplacementNamed('/main');
      // }
    }
    if (_step < 2) {
      setState(() {
        _step++;
      });
    } else {
      // Set onboarding complete flag and navigate to main shell
      // Local storage only, no Supabase
      // Import LocalStorageService and MainShell at the top:
      // import '../services/local_storage_service.dart';
      // import 'main_shell.dart';
      await Future.delayed(const Duration(milliseconds: 300));
      // ignore: use_build_context_synchronously
      await LocalStorageService.setOnboardingComplete();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D8EFF), Color(0xFFB8C6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hurdo+', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  itemCount: _cards.length,
                  controller: PageController(initialPage: _step),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _OnboardingCard(card: card);
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onButtonPressed,
                child: Text(buttonText),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCardData {
  final String title;
  final String description;
  final String imageUrl;
  const _OnboardingCardData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingCardData card;
  const _OnboardingCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(card.imageUrl, height: 160, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(card.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(card.description, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
