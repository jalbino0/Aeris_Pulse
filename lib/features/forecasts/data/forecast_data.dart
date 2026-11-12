class ForecastHour {
  final DateTime time;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  const ForecastHour({
    required this.time,
    required this.pm25,
    required this.pm10,
    required this.ozone,
  });
}

class ForecastData {
  final DateTime referenceTime;
  final List<ForecastHour> hours;
  final String timezone;
  final int utcOffsetSeconds;

  const ForecastData({
    required this.referenceTime,
    required this.hours,
    this.timezone = 'America/Sao_Paulo',
    this.utcOffsetSeconds = -10800,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourly = json['hourly'];

    if (current is! Map<String, dynamic> || hourly is! Map<String, dynamic>) {
      throw const FormatException('Resposta ambiental incompleta.');
    }

    final offsetValue = json['utc_offset_seconds'];
    final utcOffsetSeconds = offsetValue is num ? offsetValue.toInt() : -10800;

    final timezoneValue = json['timezone'];
    final timezone = timezoneValue is String && timezoneValue.trim().isNotEmpty
        ? timezoneValue
        : 'America/Sao_Paulo';

    final reference = _readTime(current['time'], utcOffsetSeconds);

    if (reference == null) {
      throw const FormatException('Horário de referência inválido.');
    }

    final times = hourly['time'];
    final pm25 = hourly['pm2_5'];
    final pm10 = hourly['pm10'];
    final ozone = hourly['ozone'];

    if (times is! List ||
        pm25 is! List ||
        pm10 is! List ||
        ozone is! List ||
        times.length != pm25.length ||
        times.length != pm10.length ||
        times.length != ozone.length) {
      throw const FormatException('Séries de previsão inválidas.');
    }

    final results = <ForecastHour>[];

    for (var i = 0; i < times.length; i++) {
      final time = _readTime(times[i], utcOffsetSeconds);

      if (time == null) {
        throw const FormatException('Data horária inválida.');
      }

      results.add(
        ForecastHour(
          time: time,
          pm25: _readNumber(pm25[i]),
          pm10: _readNumber(pm10[i]),
          ozone: _readNumber(ozone[i]),
        ),
      );
    }

    results.sort((a, b) => a.time.compareTo(b.time));

    if (results.isEmpty) {
      throw const FormatException('Previsões indisponíveis.');
    }

    if (results.map((hour) => hour.time).toSet().length != results.length) {
      throw const FormatException('Horários duplicados na previsão.');
    }

    return ForecastData(
      referenceTime: reference,
      hours: List.unmodifiable(results),
      timezone: timezone,
      utcOffsetSeconds: utcOffsetSeconds,
    );
  }

  static DateTime? _readTime(dynamic value, int utcOffsetSeconds) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value * 1000,
        isUtc: true,
      ).add(Duration(seconds: utcOffsetSeconds));
    }

    if (value is num && value.isFinite) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt() * 1000,
        isUtc: true,
      ).add(Duration(seconds: utcOffsetSeconds));
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static double? _readNumber(dynamic value) {
    if (value is! num) {
      return null;
    }

    final number = value.toDouble();

    if (!number.isFinite || number < 0) {
      return null;
    }

    return number;
  }
}
