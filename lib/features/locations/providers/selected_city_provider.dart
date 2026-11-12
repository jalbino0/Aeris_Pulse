import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cache_provider.dart';
import '../../auth/providers/auth_user_provider.dart';
import '../data/brazilian_city.dart';
import '../data/cloud_selected_city_repository.dart';
import '../data/selected_city_repository.dart';

final selectedCityRepositoryProvider = Provider<SelectedCityRepository>((ref) {
  final userId = ref.watch(authUserIdProvider).asData?.value;

  if (userId != null) {
    return CloudSelectedCityRepository(
      firestore: FirebaseFirestore.instance,
      userId: userId,
    );
  }

  return SqliteSelectedCityRepository(ref.watch(sqliteStoreProvider));
});

class SelectedCityNotifier extends AsyncNotifier<BrazilianCity> {
  @override
  Future<BrazilianCity> build() async {
    final authState = ref.watch(authUserIdProvider);

    if (!authState.hasValue) {
      await ref.watch(authUserIdProvider.future);
    }

    if (!ref.mounted) {
      throw StateError('Provider indisponível.');
    }

    return ref.read(selectedCityRepositoryProvider).getSelected();
  }

  Future<void> select(BrazilianCity city) async {
    await ref.read(selectedCityRepositoryProvider).save(city);

    if (!ref.mounted) {
      return;
    }

    state = AsyncData(city);
  }
}

final selectedCityProvider =
    AsyncNotifierProvider<SelectedCityNotifier, BrazilianCity>(
      SelectedCityNotifier.new,
    );
