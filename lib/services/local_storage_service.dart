import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  static const _onboardingKey = 'showOnboarding';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get showOnboarding => _prefs.getBool(_onboardingKey) ?? true;
  static Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingKey, false);
  }
}

final showOnboardingProvider = StateProvider<bool>((ref) {
  return LocalStorageService.showOnboarding;
});
