import '../../../core/domain/qualidade_ar_br.dart';
import '../../forecasts/data/forecast_data.dart';
import '../../forecasts/domain/forecast_analysis.dart';
import 'alert_engine.dart';

enum AlertDataStatus { ready, expired, noFutureData, insufficientData }

class SafeAlertResult {
  final AlertDataStatus status;
  final List<PredictiveAlert> alerts;
  final bool fromCache;
  final bool demonstration;
  final DateTime sourceTime;
  final DateTime? lastForecastTime;
  final int validFuturePoints;
  final int horizonHours;

  const SafeAlertResult({
    required this.status,
    required this.alerts,
    required this.fromCache,
    required this.demonstration,
    required this.sourceTime,
    required this.lastForecastTime,
    required this.validFuturePoints,
    this.horizonHours = 72,
  });

  bool get isReady => status == AlertDataStatus.ready;

  bool get canDisplayAlerts => isReady && alerts.isNotEmpty;

  double get futureCoverage {
    if (horizonHours <= 0) {
      return 0;
    }

    return (validFuturePoints / horizonHours).clamp(0.0, 1.0);
  }

  int get futureCoveragePercentage {
    return (futureCoverage * 100).round();
  }

  String get futureCoverageDescription {
    return 'O poluente com maior disponibilidade apresentou '
        '$validFuturePoints médias móveis futuras válidas '
        'em um horizonte de $horizonHours horas '
        '($futureCoveragePercentage% de cobertura). '
        'Esse percentual representa disponibilidade '
        'dos dados, não probabilidade de acerto.';
  }

  String get confidenceLevel {
    if (demonstration) {
      return 'Não aplicável';
    }

    return 'Limitada';
  }

  String get confidenceDescription {
    if (demonstration) {
      return 'Este cenário utiliza dados sintéticos. '
          'Não representa uma previsão ambiental real '
          'e não possui confiança estatística associada.';
    }

    if (!isReady) {
      return 'Não há uma análise futura válida '
          'para apresentar um nível de confiança. '
          'As condições de segurança dos dados '
          'não foram atendidas.';
    }

    return 'A confiança estatística não foi quantificada '
        'nem validada localmente. '
        'As projeções estão sujeitas às limitações '
        'do modelo atmosférico e às diferenças '
        'entre a escala regional e as condições locais.';
  }

  String get humanDecisionNotice {
    return 'Os resultados do Aeris Pulse são '
        'informações de apoio. A decisão final '
        'deve ser humana, considerando '
        'as condições locais e as orientações '
        'dos órgãos oficiais.';
  }

  String get statusTitle {
    switch (status) {
      case AlertDataStatus.ready:
        if (demonstration) {
          return 'Demonstração ilustrativa';
        }

        return fromCache ? 'Prévia armazenada' : 'Análise atualizada';

      case AlertDataStatus.expired:
        return 'Previsão desatualizada';

      case AlertDataStatus.noFutureData:
        return 'Sem previsão futura';

      case AlertDataStatus.insufficientData:
        return 'Dados insuficientes';
    }
  }

  String get statusDescription {
    switch (status) {
      case AlertDataStatus.ready:
        if (demonstration) {
          return 'Este cenário foi produzido com '
              'dados sintéticos exclusivamente '
              'para demonstrar o funcionamento '
              'do motor de alertas. '
              'Os resultados não representam '
              'condições ambientais reais.';
        }

        if (fromCache) {
          return 'A análise utiliza uma previsão '
              'armazenada localmente. '
              'As condições futuras foram reavaliadas, '
              'mas os resultados continuam sendo '
              'uma prévia offline que precisa '
              'de confirmação com dados recentes.';
        }

        return 'A análise utiliza períodos futuros '
            'e médias móveis calculadas a partir '
            'de projeções atmosféricas. '
            'Os resultados são estimativas '
            'e não avisos oficiais.';

      case AlertDataStatus.expired:
        return 'A referência da previsão está '
            'desatualizada ou inconsistente '
            'com o horário atual. '
            'Nenhum novo alerta será apresentado '
            'até que uma previsão adequada '
            'esteja disponível.';

      case AlertDataStatus.noFutureData:
        return 'O conjunto de dados não contém '
            'horários futuros dentro '
            'do horizonte selecionado. '
            'Não é possível gerar alertas '
            'sem projeções futuras.';

      case AlertDataStatus.insufficientData:
        return 'Não existem médias móveis futuras '
            'válidas suficientes para uma análise '
            'segura. O maior número de pontos '
            'válidos encontrado foi '
            '$validFuturePoints, abaixo do mínimo '
            'necessário de 6.';
    }
  }
}

class SafeAlertEngine {
  static const Duration maximumReferenceAge = Duration(hours: 4);
  static const int minimumValidFuturePoints = 6;

  static SafeAlertResult evaluate(
    ForecastData data, {
    DateTime? now,
    int horizonHours = 72,
    bool fromCache = false,
    bool demonstration = false,
  }) {
    if (horizonHours <= 0) {
      throw ArgumentError.value(horizonHours, 'horizonHours');
    }

    final instant = (now ?? DateTime.now()).toUtc();

    final cityNow = instant.add(Duration(seconds: data.utcOffsetSeconds));

    final sourceWall = _wallClock(data.referenceTime);

    final currentWall = demonstration ? sourceWall : _wallClock(cityNow);

    DateTime? lastForecastTime;

    for (final hour in data.hours) {
      if (lastForecastTime == null ||
          _wallClock(hour.time).isAfter(_wallClock(lastForecastTime))) {
        lastForecastTime = hour.time;
      }
    }

    SafeAlertResult createResult(
      AlertDataStatus status, {
      List<PredictiveAlert> alerts = const [],
      int validFuturePoints = 0,
    }) {
      return SafeAlertResult(
        status: status,
        alerts: List.unmodifiable(alerts),
        fromCache: fromCache,
        demonstration: demonstration,
        sourceTime: data.referenceTime,
        lastForecastTime: lastForecastTime,
        validFuturePoints: validFuturePoints,
        horizonHours: horizonHours,
      );
    }

    final age = currentWall.difference(sourceWall);

    if (age > maximumReferenceAge || age < const Duration(hours: -1)) {
      return createResult(AlertDataStatus.expired);
    }

    final horizonEnd = currentWall.add(Duration(hours: horizonHours));

    final futureHours = data.hours.where((hour) {
      final time = _wallClock(hour.time);

      return time.isAfter(currentWall) && !time.isAfter(horizonEnd);
    }).toList();

    if (futureHours.isEmpty) {
      return createResult(AlertDataStatus.noFutureData);
    }

    final reference = demonstration
        ? data.referenceTime
        : _referenceAt(cityNow, data.referenceTime.isUtc);

    final adjustedData = ForecastData(
      referenceTime: reference,
      hours: data.hours,
      timezone: data.timezone,
      utcOffsetSeconds: data.utcOffsetSeconds,
    );

    var maximumValidPoints = 0;

    for (final pollutant in PoluenteBr.values) {
      final points = ForecastAnalysis.calculate(
        adjustedData,
        pollutant,
        horizonHours,
      );

      final validCount = points.where((point) {
        if (point.average == null) {
          return false;
        }

        final time = _wallClock(point.time);

        return time.isAfter(currentWall) && !time.isAfter(horizonEnd);
      }).length;

      if (validCount > maximumValidPoints) {
        maximumValidPoints = validCount;
      }
    }

    if (maximumValidPoints < minimumValidFuturePoints) {
      return createResult(
        AlertDataStatus.insufficientData,
        validFuturePoints: maximumValidPoints,
      );
    }

    final generated = AlertEngine.generate(
      adjustedData,
      horizonHours: horizonHours,
      demonstration: demonstration,
    );

    final validAlerts = generated.where((alert) {
      final peakTime = _wallClock(alert.peakTime);

      return peakTime.isAfter(currentWall) && !peakTime.isAfter(horizonEnd);
    }).toList();

    return createResult(
      AlertDataStatus.ready,
      alerts: validAlerts,
      validFuturePoints: maximumValidPoints,
    );
  }

  static DateTime _wallClock(DateTime value) {
    return DateTime.utc(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
    );
  }

  static DateTime _referenceAt(DateTime cityNow, bool utc) {
    if (utc) {
      return DateTime.utc(
        cityNow.year,
        cityNow.month,
        cityNow.day,
        cityNow.hour,
      );
    }

    return DateTime(cityNow.year, cityNow.month, cityNow.day, cityNow.hour);
  }
}
