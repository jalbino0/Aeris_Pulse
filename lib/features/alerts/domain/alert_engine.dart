import '../../../core/domain/qualidade_ar_br.dart';
import '../../forecasts/data/forecast_data.dart';
import '../../forecasts/domain/forecast_analysis.dart';

enum AlertPriority { preventiva, elevada, critica }

class PredictiveAlert {
  final String id;
  final PoluenteBr pollutant;
  final AlertPriority priority;
  final FaixaQualidadeAr classification;
  final DateTime referenceTime;
  final DateTime peakTime;
  final double peakAverage;
  final double? referenceAverage;
  final int referenceHours;
  final int availablePoints;
  final int expectedPoints;
  final bool demonstration;

  const PredictiveAlert({
    required this.id,
    required this.pollutant,
    required this.priority,
    required this.classification,
    required this.referenceTime,
    required this.peakTime,
    required this.peakAverage,
    required this.referenceAverage,
    required this.referenceHours,
    required this.availablePoints,
    required this.expectedPoints,
    required this.demonstration,
  });

  double get coverage {
    if (expectedPoints <= 0) {
      return 0;
    }

    return availablePoints / expectedPoints;
  }

  int get coveragePercentage {
    return (coverage * 100).clamp(0, 100).round();
  }

  String get coverageLabel {
    return '$coveragePercentage% '
        '($availablePoints de $expectedPoints médias válidas)';
  }

  String get coverageLevel {
    if (coverage >= 0.9) {
      return 'Cobertura ampla';
    }

    if (coverage >= 0.7) {
      return 'Cobertura parcial';
    }

    return 'Cobertura reduzida';
  }

  double? get variation {
    if (referenceAverage == null) {
      return null;
    }

    return peakAverage - referenceAverage!;
  }

  int get leadTimeMinutes {
    final difference = peakTime.difference(referenceTime).inMinutes;

    return difference > 0 ? difference : 0;
  }

  String get leadTimeLabel {
    final minutes = leadTimeMinutes;

    if (minutes <= 0) {
      return 'Sem antecedência positiva identificada';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$minutes minutos';
    }

    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hora' : 'horas'}';
    }

    return '$hours h e $remainingMinutes min';
  }

  String get pollutantName {
    return switch (pollutant) {
      PoluenteBr.mp25 => 'MP2,5',
      PoluenteBr.mp10 => 'MP10',
      PoluenteBr.ozonio => 'Ozônio',
    };
  }

  String get priorityName {
    return switch (priority) {
      AlertPriority.preventiva => 'Atenção preventiva',
      AlertPriority.elevada => 'Atenção elevada',
      AlertPriority.critica => 'Atenção crítica',
    };
  }

  String get title {
    final difference = variation;

    final baseline = referenceAverage == null
        ? null
        : QualidadeArBr.classificarMedia(pollutant, referenceAverage!);

    if (difference != null &&
        difference > 0 &&
        baseline == FaixaQualidadeAr.boa) {
      return 'Possível piora prevista de $pollutantName';
    }

    return 'Condição ${classification.nome.toLowerCase()} '
        'prevista para $pollutantName';
  }

  String get confidenceLevel {
    if (demonstration) {
      return 'Não aplicável';
    }

    return 'Limitada';
  }

  String get confidenceExplanation {
    if (demonstration) {
      return 'Este cenário utiliza dados sintéticos. '
          'Não existe previsão real nem nível de confiança '
          'estatístico associado à simulação.';
    }

    return 'A confiança da previsão é considerada limitada '
        'porque não existe validação estatística local '
        'nem calibração de probabilidades neste aplicativo. '
        'A série apresenta $coverageLabel. '
        'Essa cobertura informa a disponibilidade '
        'das médias calculadas, não a probabilidade '
        'de o alerta acontecer.';
  }

  String get evidenceSummary {
    final average = _formatValue(peakAverage);

    return 'O modelo prevê uma maior média móvel '
        'de $average µg/m³ para $pollutantName, '
        'considerando uma janela de $referenceHours horas. '
        'O valor corresponde à faixa ${classification.nome} '
        'da classificação brasileira de qualidade do ar. '
        'Foram obtidas $availablePoints médias válidas '
        'em um horizonte esperado de $expectedPoints horas.';
  }

  String get variationSummary {
    final difference = variation;

    if (difference == null) {
      return 'Não há média de referência suficiente '
          'para calcular a variação prevista.';
    }

    final formatted = _formatValue(difference.abs());

    if (difference > 0) {
      return 'Aumento estimado de $formatted µg/m³ '
          'em relação à média de referência.';
    }

    if (difference < 0) {
      return 'Redução estimada de $formatted µg/m³ '
          'em relação à média de referência.';
    }

    return 'Não há variação entre a maior média prevista '
        'e a média de referência.';
  }

  String get socialBenefitIndicator {
    if (demonstration) {
      return 'Indicador ilustrativo: '
          '$leadTimeLabel entre a referência '
          'da simulação e o pico estimado.';
    }

    if (leadTimeMinutes <= 0) {
      return 'Não foi identificada antecedência positiva '
          'entre a referência da previsão e o pico.';
    }

    return 'Antecedência potencial de $leadTimeLabel '
        'entre a referência da previsão '
        'e o pico estimado. '
        'Esse intervalo pode apoiar o planejamento '
        'preventivo, mas não representa um benefício '
        'social diretamente medido nem garante '
        'que a previsão se concretize.';
  }

  String get humanDecisionNotice {
    return 'Este alerta é um apoio informativo. '
        'A decisão final deve ser tomada por uma pessoa, '
        'considerando as condições locais '
        'e as orientações dos órgãos oficiais.';
  }

  String get limitations {
    return 'Previsão modelada sem validação estatística local '
        'neste aplicativo. O CAMS Global possui resolução '
        'espacial regional, e condições locais podem divergir. '
        'A confiança não representa uma probabilidade '
        'de ocorrência. Dados incompletos também podem '
        'reduzir a cobertura da análise. '
        'As projeções não substituem medições oficiais '
        'nem recomendações de autoridades ambientais.';
  }

  static String _formatValue(double value) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class AlertEngine {
  static List<PredictiveAlert> generate(
    ForecastData data, {
    int horizonHours = 72,
    bool demonstration = false,
  }) {
    if (horizonHours <= 0) {
      throw ArgumentError('Horizonte inválido.');
    }

    final alerts = <PredictiveAlert>[];

    for (final pollutant in PoluenteBr.values) {
      final points = ForecastAnalysis.calculate(data, pollutant, horizonHours);

      final valid = points.where((point) => point.average != null).toList();

      if (valid.length < 6) {
        continue;
      }

      final peak = ForecastAnalysis.peak(valid);

      if (peak == null ||
          peak.average == null ||
          peak.classification == null ||
          peak.classification == FaixaQualidadeAr.boa) {
        continue;
      }

      final priority = switch (peak.classification!) {
        FaixaQualidadeAr.boa => AlertPriority.preventiva,
        FaixaQualidadeAr.moderada => AlertPriority.preventiva,
        FaixaQualidadeAr.ruim => AlertPriority.elevada,
        FaixaQualidadeAr.muitoRuim ||
        FaixaQualidadeAr.pessima => AlertPriority.critica,
      };

      alerts.add(
        PredictiveAlert(
          id: pollutant.name,
          pollutant: pollutant,
          priority: priority,
          classification: peak.classification!,
          referenceTime: data.referenceTime,
          peakTime: peak.time,
          peakAverage: peak.average!,
          referenceAverage: ForecastAnalysis.rollingAverage(
            data,
            pollutant,
            data.referenceTime,
          ),
          referenceHours: QualidadeArBr.janelaHoras(pollutant),
          availablePoints: valid.length,
          expectedPoints: horizonHours,
          demonstration: demonstration,
        ),
      );
    }

    alerts.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      return a.peakTime.compareTo(b.peakTime);
    });

    return alerts;
  }
}

class DemonstrationForecast {
  static ForecastData create({DateTime? referenceTime}) {
    final now = referenceTime ?? DateTime.now();

    final reference = DateTime(now.year, now.month, now.day, now.hour);

    final hours = List.generate(96, (index) {
      final offset = index - 23;
      final future = offset > 0;

      return ForecastHour(
        time: reference.add(Duration(hours: offset)),
        pm25: future ? 60 : 12,
        pm10: future ? 110 : 30,
        ozone: future ? 140 : 60,
      );
    });

    return ForecastData(
      referenceTime: reference,
      hours: List.unmodifiable(hours),
    );
  }
}
