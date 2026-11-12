import '../../../core/domain/qualidade_ar_br.dart';
import '../data/forecast_data.dart';

class ForecastPoint {
  final DateTime time;
  final double? average;
  final FaixaQualidadeAr? classification;

  const ForecastPoint({
    required this.time,
    required this.average,
    required this.classification,
  });
}

class ForecastAnalysis {
  static double? concentration(ForecastHour hour, PoluenteBr pollutant) {
    return switch (pollutant) {
      PoluenteBr.mp25 => hour.pm25,
      PoluenteBr.mp10 => hour.pm10,
      PoluenteBr.ozonio => hour.ozone,
    };
  }

  static double? rollingAverage(
    ForecastData data,
    PoluenteBr pollutant,
    DateTime time,
  ) {
    final requiredHours = QualidadeArBr.janelaHoras(pollutant);

    final samples = {for (final hour in data.hours) hour.time: hour};

    final values = <double>[];

    for (var i = 0; i < requiredHours; i++) {
      final expected = time.subtract(Duration(hours: i));
      final hour = samples[expected];

      if (hour == null) return null;

      final value = concentration(hour, pollutant);

      if (value == null || !value.isFinite || value < 0) {
        return null;
      }

      values.add(value);
    }

    return QualidadeArBr.calcularMedia(pollutant, values);
  }

  static List<ForecastPoint> calculate(
    ForecastData data,
    PoluenteBr pollutant,
    int horizonHours,
  ) {
    if (horizonHours <= 0) {
      throw ArgumentError('Horizonte inválido.');
    }

    final results = <ForecastPoint>[];

    for (var i = 1; i <= horizonHours; i++) {
      final time = data.referenceTime.add(Duration(hours: i));
      final average = rollingAverage(data, pollutant, time);

      results.add(
        ForecastPoint(
          time: time,
          average: average,
          classification: average == null
              ? null
              : QualidadeArBr.classificarMedia(pollutant, average),
        ),
      );
    }

    return results;
  }

  static ForecastPoint? peak(List<ForecastPoint> points) {
    ForecastPoint? result;

    for (final point in points) {
      if (point.average == null) continue;

      if (result == null || point.average! > result.average!) {
        result = point;
      }
    }

    return result;
  }

  static List<ForecastPoint> dailyPeaks(List<ForecastPoint> points) {
    final daily = <DateTime, ForecastPoint>{};

    for (final point in points) {
      if (point.average == null) continue;

      final day = DateTime(point.time.year, point.time.month, point.time.day);

      final previous = daily[day];

      if (previous == null || point.average! > previous.average!) {
        daily[day] = point;
      }
    }

    return daily.values.toList();
  }
}
