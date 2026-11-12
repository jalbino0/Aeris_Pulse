import 'dart:convert';

import 'package:http/http.dart' as http;

import 'brazilian_city.dart';

class CitySearchService {
  final http.Client client;

  const CitySearchService(this.client);

  Future<List<BrazilianCity>> search(String query) async {
    final term = query.trim();

    if (term.length < 3) {
      return [];
    }

    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': term,
      'count': '20',
      'language': 'pt',
      'countryCode': 'BR',
      'format': 'json',
    });

    final response = await client.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar cidades: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Resposta da busca de cidades inválida.');
    }

    final results = decoded['results'];

    if (results == null) {
      return [];
    }

    if (results is! List) {
      throw const FormatException('Lista de localidades inválida.');
    }

    final cities = <BrazilianCity>[];
    final ids = <int>{};

    for (final result in results) {
      if (result is! Map<String, dynamic>) {
        continue;
      }

      if (result['country_code'] != 'BR') {
        continue;
      }

      final featureCode = result['feature_code'];

      if (featureCode is! String || !featureCode.startsWith('PPL')) {
        continue;
      }

      try {
        final city = BrazilianCity.fromApi(result);

        if (ids.add(city.id)) {
          cities.add(city);
        }
      } on FormatException {
        continue;
      }
    }

    return cities;
  }
}
