import 'package:shared_preferences/shared_preferences.dart';

class EntryPreferences {
  static const String _completedKey = 'aeris_onboarding_completed';

  const EntryPreferences();

  Future<bool> shouldShowWelcome() async {
    final preferences = await SharedPreferences.getInstance();

    return !(preferences.getBool(_completedKey) ?? false);
  }

  Future<void> markCompleted() async {
    final preferences = await SharedPreferences.getInstance();

    final saved = await preferences.setBool(_completedKey, true);

    if (!saved) {
      throw StateError('Não foi possível salvar a preferência de entrada.');
    }
  }
}
