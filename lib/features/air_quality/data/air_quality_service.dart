import '../../../core/network/cached_api_client.dart';
import '../../../core/network/environment_cache_keys.dart';
import '../../locations/data/brazilian_city.dart';
import '../../locations/data/selected_city_repository.dart';
import 'air_quality_reading.dart';

class AirQualityService {
  final CachedApiClient client;

  const AirQualityService(this.client);

  Future<CachedApiResult<AirQualityReading>> fetchCity(BrazilianCity city) {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'pm2_5,pm10,ozone',
      'timezone': city.timezone,
      'domains': 'cams_global',
    });

    return client.fetch<AirQualityReading>(
      key: EnvironmentCacheKeys.api(city, 'home_citytime_v2'),
      uri: uri,
      parse: (json) {
        final current = json['current'];

        if (current is! Map<String, dynamic>) {
          throw const FormatException('Dados ambientais indisponíveis.');
        }

        final time = current['time'];

        if (time is! String || time.isEmpty) {
          throw const FormatException('Horário de referência inválido.');
        }

        final pm25 = _concentration(current['pm2_5']);
        final pm10 = _concentration(current['pm10']);
        final ozone = _concentration(current['ozone']);

        if (pm25 == null && pm10 == null && ozone == null) {
          throw const FormatException(
            'Nenhuma concentração ambiental disponível.',
          );
        }

        return AirQualityReading(
          location: '${city.name} (${city.state})',
          referenceTime: time,
          pm25: pm25,
          pm10: pm10,
          ozone: ozone,
        );
      },
    );
  }

  Future<CachedApiResult<AirQualityReading>> fetchSaoPaulo() {
    return fetchCity(SqliteSelectedCityRepository.defaultCity);
  }

  double? _concentration(dynamic value) {
    if (value is! num) {
      return null;
    }

    final concentration = value.toDouble();

    if (!concentration.isFinite || concentration < 0) {
      return null;
    }

    return concentration;
  }
}
