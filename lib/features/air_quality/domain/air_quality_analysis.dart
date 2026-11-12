import '../../../core/domain/qualidade_ar_br.dart';
import '../data/air_quality_history.dart';

class AirQualityAnalysis {
  static double? concentration(AirQualityHour hour, PoluenteBr pollutant) {
    return switch (pollutant) {
      PoluenteBr.mp25 => hour.pm25,
      PoluenteBr.mp10 => hour.pm10,
      PoluenteBr.ozonio => hour.ozone,
    };
  }

  static DateTime _hourKey(DateTime time) {
    return DateTime.utc(time.year, time.month, time.day, time.hour);
  }

  static double? referenceAverage(
    AirQualityHistory history,
    PoluenteBr pollutant,
  ) {
    final requiredHours = QualidadeArBr.janelaHoras(pollutant);

    final reference = _hourKey(history.referenceTime);

    final samplesByTime = {
      for (final sample in history.hours) _hourKey(sample.time): sample,
    };

    final values = <double>[];

    for (var i = 0; i < requiredHours; i++) {
      final expectedTime = reference.subtract(Duration(hours: i));

      final sample = samplesByTime[expectedTime];

      if (sample == null) {
        return null;
      }

      final value = concentration(sample, pollutant);

      if (value == null || !value.isFinite || value < 0) {
        return null;
      }

      values.add(value);
    }

    return QualidadeArBr.calcularMedia(pollutant, values);
  }

  static FaixaQualidadeAr? referenceClassification(
    AirQualityHistory history,
    PoluenteBr pollutant,
  ) {
    final average = referenceAverage(history, pollutant);

    if (average == null) {
      return null;
    }

    return QualidadeArBr.classificarMedia(pollutant, average);
  }
}
