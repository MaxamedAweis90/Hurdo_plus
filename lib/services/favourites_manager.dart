import 'package:flutter/foundation.dart';
import 'package:hurdo_plus/models/sound_model.dart';

class FavouritesManager extends ChangeNotifier {
  static final FavouritesManager _instance = FavouritesManager._internal();
  factory FavouritesManager() => _instance;
  FavouritesManager._internal();

  final List<SoundModel> _favourites = [];

  List<SoundModel> get favourites => List.unmodifiable(_favourites);

  bool isFavourite(SoundModel sound) {
    return _favourites.any((s) => s.url == sound.url);
  }

  void add(SoundModel sound) {
    if (!isFavourite(sound)) {
      _favourites.add(sound);
      notifyListeners();
    }
  }

  void remove(SoundModel sound) {
    _favourites.removeWhere((s) => s.url == sound.url);
    notifyListeners();
  }
}
