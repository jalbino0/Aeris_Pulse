
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aeris_pulse/features/locations/data/brazilian_city.dart';
import 'package:aeris_pulse/features/locations/data/city_search_service.dart';

void main() {
  Map<String, dynamic> sampleCity() {
    return {
      'id': 1001,
      'name': 'Campinas',
      'admin1': 'São Paulo',
      'latitude': -22.9056,
      'longitude': -47.0608,
      'timezone': 'America/Sao_Paulo',
      'country_code': 'BR',
      'feature_code': 'PPLA2',
    };
  }

  http.Response jsonResponse(
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(data)),
      statusCode,
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }

  test('Interpreta uma cidade brasileira válida', () {
    final city = BrazilianCity.fromApi(sampleCity());

    expect(city.id, 1001);
    expect(city.name, 'Campinas');
    expect(city.state, 'São Paulo');
    expect(city.latitude, -22.9056);
    expect(city.longitude, -47.0608);
    expect(city.displayName, 'Campinas • São Paulo');
  });

  test('Converte cidade para armazenamento local', () {
    final city = BrazilianCity.fromApi(sampleCity());

    final restored = BrazilianCity.fromDatabase(
      city.toDatabase(),
    );

    expect(restored.id, city.id);
    expect(restored.name, city.name);
    expect(restored.state, city.state);
    expect(restored.latitude, city.latitude);
    expect(restored.longitude, city.longitude);
    expect(restored.timezone, city.timezone);
  });

  test('Busca cidades utilizando o filtro brasileiro', () async {
    final client = MockClient((request) async {
      expect(
        request.url.queryParameters['countryCode'],
        'BR',
      );

      expect(
        request.url.queryParameters['language'],
        'pt',
      );

      expect(
        request.url.queryParameters['name'],
        'Campinas',
      );

      return jsonResponse({
        'results': [sampleCity()],
      });
    });

    final service = CitySearchService(client);

    final cities = await service.search('Campinas');

    expect(cities.length, 1);
    expect(cities.first.name, 'Campinas');
    expect(cities.first.state, 'São Paulo');

    client.close();
  });

  test('Ignora localidades fora do Brasil', () async {
    final cityOutsideBrazil = {
      ...sampleCity(),
      'id': 2002,
      'country_code': 'US',
    };

    final client = MockClient((request) async {
      return jsonResponse({
        'results': [
          sampleCity(),
          cityOutsideBrazil,
        ],
      });
    });

    final service = CitySearchService(client);

    final cities = await service.search('Campinas');

    expect(cities.length, 1);
    expect(cities.first.id, 1001);

    client.close();
  });

  test('Ignora regiões que não são localidades habitadas', () async {
    final region = {
      ...sampleCity(),
      'id': 3003,
      'feature_code': 'ADM1',
    };

    final client = MockClient((request) async {
      return jsonResponse({
        'results': [region],
      });
    });

    final service = CitySearchService(client);

    final cities = await service.search('Campinas');

    expect(cities, isEmpty);

    client.close();
  });

  test('Não consulta API para termos muito curtos', () async {
    var calls = 0;

    final client = MockClient((request) async {
      calls++;
      return jsonResponse({});
    });

    final service = CitySearchService(client);

    final cities = await service.search('Ca');

    expect(cities, isEmpty);
    expect(calls, 0);

    client.close();
  });

  test('Retorna lista vazia quando não existem resultados', () async {
    final client = MockClient((request) async {
      return jsonResponse({});
    });

    final service = CitySearchService(client);

    final cities = await service.search('CidadeInexistente');

    expect(cities, isEmpty);

    client.close();
  });

  test('Rejeita uma resposta HTTP inválida', () async {
    final client = MockClient((request) async {
      return jsonResponse({}, statusCode: 500);
    });

    final service = CitySearchService(client);

    await expectLater(
      service.search('Campinas'),
      throwsException,
    );

    client.close();
  });
}
