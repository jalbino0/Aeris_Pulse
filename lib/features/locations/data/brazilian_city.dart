class BrazilianCity {
  final int id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final String timezone;

  const BrazilianCity({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  String get displayName => '$name • $state';

  factory BrazilianCity.fromApi(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final state = json['admin1'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final timezone = json['timezone'];

    if (id is! num ||
        name is! String ||
        state is! String ||
        latitude is! num ||
        longitude is! num ||
        timezone is! String ||
        name.trim().isEmpty ||
        state.trim().isEmpty ||
        timezone.trim().isEmpty) {
      throw const FormatException('Dados de cidade inválidos.');
    }

    final lat = latitude.toDouble();
    final lon = longitude.toDouble();

    if (!lat.isFinite ||
        !lon.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lon < -180 ||
        lon > 180) {
      throw const FormatException('Coordenadas inválidas.');
    }

    return BrazilianCity(
      id: id.toInt(),
      name: name.trim(),
      state: state.trim(),
      latitude: lat,
      longitude: lon,
      timezone: timezone.trim(),
    );
  }

  factory BrazilianCity.fromDatabase(Map<String, Object?> row) {
    return BrazilianCity(
      id: row['id'] as int,
      name: row['name'] as String,
      state: row['state'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      timezone: row['timezone'] as String,
    );
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}
