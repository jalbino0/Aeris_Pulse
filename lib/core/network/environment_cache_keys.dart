import '../../features/locations/data/brazilian_city.dart';

class EnvironmentCacheKeys {
  static bool _isDefaultSaoPaulo(BrazilianCity city) {
    return city.id == 0 &&
        city.latitude == -23.5505 &&
        city.longitude == -46.6333;
  }

  static String _identifier(BrazilianCity city) {
    final latitude = city.latitude.toStringAsFixed(6);
    final longitude = city.longitude.toStringAsFixed(6);

    return '${city.id}_${latitude}_$longitude';
  }

  static String api(BrazilianCity city, String resource) {
    if (_isDefaultSaoPaulo(city)) {
      switch (resource) {
        case 'home':
          return 'air_quality_current_sao_paulo';
        case 'history':
          return 'air_quality_history_sao_paulo_v1';
        case 'forecast':
          return 'air_quality_forecast_sao_paulo_v1';
      }
    }

    return 'environment_${resource}_${_identifier(city)}_v1';
  }

  static String status(BrazilianCity city, String resource) {
    return 'status_${resource}_${_identifier(city)}';
  }
}
