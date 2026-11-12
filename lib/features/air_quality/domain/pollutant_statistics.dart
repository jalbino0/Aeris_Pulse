import '../../../core/domain/qualidade_ar_br.dart';
import '../data/air_quality_history.dart';
import 'air_quality_analysis.dart';

class PollutantStatistics {
  final double? latest;
  final double? previous;
  final double? referenceAverage;
  final double? minimum;
  final double? maximum;
  final int validSamples;
  final FaixaQualidadeAr? classification;

  const PollutantStatistics({
    required this.latest,
    required this.previous,
    required this.referenceAverage,
    required this.minimum,
    required this.maximum,
    required this.validSamples,
    required this.classification,
  });

  double? get hourlyChange {
    if (latest == null || previous == null) return null;
    return latest! - previous!;
  }

  static PollutantStatistics fromHistory(
    AirQualityHistory history,
    PoluenteBr pollutant,
  ) {
    double? latest;
    double? previous;
    double? minimum;
    double? maximum;
    var validSamples = 0;

    final previousTime = history.referenceTime.subtract(
      const Duration(hours: 1),
    );

    for (final hour in history.hours) {
      final value = AirQualityAnalysis.concentration(hour, pollutant);

      if (value == null || !value.isFinite || value < 0) continue;

      validSamples++;
      minimum = minimum == null || value < minimum ? value : minimum;
      maximum = maximum == null || value > maximum ? value : maximum;

      if (hour.time == history.referenceTime) {
        latest = value;
      }

      if (hour.time == previousTime) {
        previous = value;
      }
    }

    return PollutantStatistics(
      latest: latest,
      previous: previous,
      referenceAverage: AirQualityAnalysis.referenceAverage(history, pollutant),
      minimum: minimum,
      maximum: maximum,
      validSamples: validSamples,
      classification: AirQualityAnalysis.referenceClassification(
        history,
        pollutant,
      ),
    );
  }
}
