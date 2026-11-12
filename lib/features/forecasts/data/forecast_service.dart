import '../../../core/network/cached_api_client.dart';
import '../../../core/network/environment_cache_keys.dart';
import '../../locations/data/brazilian_city.dart';
import '../../locations/data/selected_city_repository.dart';
import 'forecast_data.dart';

class ForecastService {
  final CachedApiClient client;

  const ForecastService(this.client);

  Future<CachedApiResult<ForecastData>> fetchForecast({BrazilianCity? city}) {
    final monitoredCity = city ?? SqliteSelectedCityRepository.defaultCity;

    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': monitoredCity.latitude.toString(),
      'longitude': monitoredCity.longitude.toString(),
      'current': 'pm2_5,pm10,ozone',
      'hourly': 'pm2_5,pm10,ozone',
      'past_days': '2',
      'forecast_days': '5',
      'timezone': monitoredCity.timezone,
      'timeformat': 'unixtime',
      'domains': 'cams_global',
    });

    return client.fetch<ForecastData>(
      key: EnvironmentCacheKeys.api(monitoredCity, 'forecast_citytime_v2'),
      uri: uri,
      parse: ForecastData.fromJson,
    );
  }
}
