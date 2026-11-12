import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../data/air_quality_reading.dart';
import '../data/air_quality_service.dart';

final airQualityServiceProvider = Provider<AirQualityService>((ref) {
  return AirQualityService(ref.watch(cachedApiClientProvider));
});

final airQualityProvider = FutureProvider<AirQualityReading>((ref) async {
  final service = ref.watch(airQualityServiceProvider);
  final city = await ref.watch(selectedCityProvider.future);

  final result = await service.fetchCity(city);

  if (ref.mounted) {
    final statuses = ref.read(cacheStatusProvider.notifier);

    statuses.register('home', result);
    statuses.register(EnvironmentCacheKeys.status(city, 'home'), result);
  }

  return result.data;
});
