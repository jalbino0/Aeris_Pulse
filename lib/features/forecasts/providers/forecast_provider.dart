import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../data/forecast_data.dart';
import '../data/forecast_service.dart';

final forecastServiceProvider = Provider<ForecastService>((ref) {
  return ForecastService(ref.watch(cachedApiClientProvider));
});

final forecastProvider = FutureProvider<ForecastData>((ref) async {
  final service = ref.watch(forecastServiceProvider);
  final city = await ref.watch(selectedCityProvider.future);

  final result = await service.fetchForecast(city: city);

  if (ref.mounted) {
    final statuses = ref.read(cacheStatusProvider.notifier);

    statuses.register('forecast', result);
    statuses.register(EnvironmentCacheKeys.status(city, 'forecast'), result);
  }

  return result.data;
});
