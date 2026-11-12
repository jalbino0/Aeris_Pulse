class AirQualityHour {
  final DateTime time;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  const AirQualityHour({
    required this.time,
    required this.pm25,
    required this.pm10,
    required this.ozone,
  });
}

class AirQualityHistory {
  final DateTime referenceTime;
  final List<AirQualityHour> hours;
  final String timezone;
  final int utcOffsetSeconds;

  const AirQualityHistory({
    required this.referenceTime,
    required this.hours,
    this.timezone = '',
    this.utcOffsetSeconds = 0,
  });

  factory AirQualityHistory.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourly = json['hourly'];

    if (current is! Map<String, dynamic> || hourly is! Map<String, dynamic>) {
      throw const FormatException('Dados horários indisponíveis.');
    }

    final offsetValue = json['utc_offset_seconds'];

    if (current['time'] is num && offsetValue is! num) {
      throw const FormatException('Fuso horário da previsão indisponível.');
    }

    final utcOffsetSeconds = offsetValue is num ? offsetValue.toInt() : 0;

    final timezoneValue = json['timezone'];
    final timezone = timezoneValue is String ? timezoneValue : '';

    final reference = _readTime(current['time'], utcOffsetSeconds);

    if (reference == null) {
      throw const FormatException('Horário de referência inválido.');
    }

    final times = hourly['time'];
    final pm25 = hourly['pm2_5'];
    final pm10 = hourly['pm10'];
    final ozone = hourly['ozone'];

    if (times is! List || pm25 is! List || pm10 is! List || ozone is! List) {
      throw const FormatException('Séries horárias inválidas.');
    }

    if (times.length != pm25.length ||
        times.length != pm10.length ||
        times.length != ozone.length) {
      throw const FormatException('As séries possuem tamanhos diferentes.');
    }

    final referenceHour = reference.isUtc
        ? DateTime.utc(
            reference.year,
            reference.month,
            reference.day,
            reference.hour,
          )
        : DateTime(
            reference.year,
            reference.month,
            reference.day,
            reference.hour,
          );

    final start = referenceHour.subtract(const Duration(hours: 23));

    final samples = <AirQualityHour>[];

    for (var i = 0; i < times.length; i++) {
      final time = _readTime(times[i], utcOffsetSeconds);

      if (time == null || time.isBefore(start) || time.isAfter(referenceHour)) {
        continue;
      }

      samples.add(
        AirQualityHour(
          time: time,
          pm25: _concentration(pm25[i]),
          pm10: _concentration(pm10[i]),
          ozone: _concentration(ozone[i]),
        ),
      );
    }

    samples.sort((a, b) => a.time.compareTo(b.time));

    if (samples.isEmpty ||
        samples.every(
          (sample) =>
              sample.pm25 == null &&
              sample.pm10 == null &&
              sample.ozone == null,
        )) {
      throw const FormatException('Nenhuma concentração válida disponível.');
    }

    return AirQualityHistory(
      referenceTime: referenceHour,
      hours: List.unmodifiable(samples),
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

  static double? _concentration(dynamic value) {
    if (value is! num) {
      return null;
    }

    final result = value.toDouble();

    if (!result.isFinite || result < 0) {
      return null;
    }

    return result;
  }
}
