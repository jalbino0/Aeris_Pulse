import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final predictiveAlertsEnabledProvider =
    AsyncNotifierProvider<PredictiveAlertsEnabledNotifier, bool>(
      PredictiveAlertsEnabledNotifier.new,
    );

class PredictiveAlertsEnabledNotifier extends AsyncNotifier<bool> {
  static const _key = 'aeris_predictive_alerts_enabled';

  @override
  Future<bool> build() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final previous = state.asData?.value ?? true;

    state = AsyncData(enabled);

    try {
      final preferences = await SharedPreferences.getInstance();

      final saved = await preferences.setBool(_key, enabled);

      if (!saved) {
        throw StateError('Não foi possível salvar a preferência.');
      }
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
