import 'package:flutter/widgets.dart';

class AppAudioController extends ChangeNotifier {
  double _volume = 0.7; // 0..1

  double get volume => _volume;

  void setVolume(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v != _volume) {
      _volume = v;
      notifyListeners();
    }
  }
}

class AppAudioScope extends InheritedNotifier<AppAudioController> {
  const AppAudioScope({
    super.key,
    required AppAudioController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppAudioController of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppAudioScope>();
    assert(widget != null, 'AppAudioScope not found in context');
    return widget!.notifier!;
  }

  static AppAudioController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppAudioScope>()
        ?.notifier;
  }
}
