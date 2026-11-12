import '../../../core/network/cached_api_client.dart';
import '../../../core/network/environment_cache_keys.dart';
import '../../locations/data/brazilian_city.dart';
import '../../locations/data/selected_city_repository.dart';
import 'air_quality_history.dart';

class AirQualityHistoryService {
  final CachedApiClient client;

  const AirQualityHistoryService(this.client);

  Future<CachedApiResult<AirQualityHistory>> fetchCityHistory(
    BrazilianCity city,
  ) {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'pm2_5,pm10,ozone',
      'hourly': 'pm2_5,pm10,ozone',
      'past_days': '2',
      'forecast_days': '1',
      'timezone': city.timezone,
      'timeformat': 'unixtime',
      'domains': 'cams_global',
    });

    return client.fetch<AirQualityHistory>(
      key: '${EnvironmentCacheKeys.api(city, 'history')}_citytime_v3',
      uri: uri,
      parse: AirQualityHistory.fromJson,
    );
  }

  Future<CachedApiResult<AirQualityHistory>> fetchSaoPauloHistory() {
    return fetchCityHistory(SqliteSelectedCityRepository.defaultCity);
  }
}
