import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/air_quality/providers/air_quality_provider.dart';
import '../../features/air_quality/providers/air_quality_history_provider.dart';
import '../../features/forecasts/providers/forecast_provider.dart';
import 'cache_provider.dart';

class GlobalRefreshResult {
  final int successful;
  final int failed;
  final int fromCache;

  const GlobalRefreshResult({
    required this.successful,
    required this.failed,
    required this.fromCache,
  });

  String get message {
    if (failed == 3) {
      return 'Não foi possível consultar os dados ambientais. '
          'Verifique a conexão e tente novamente.';
    }

    if (failed > 0) {
      return '$successful conjuntos de dados disponíveis. '
          '$failed consultas falharam. Verifique as seções.';
    }

    if (fromCache > 0) {
      return 'Consultas concluídas. '
          '$fromCache conjuntos de dados vieram do SQLite '
          'e podem estar desatualizados.';
    }

    return 'Dados ambientais sincronizados com sucesso.';
  }
}

class GlobalRefreshController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<GlobalRefreshResult> refreshAll() async {
    if (state) {
      return const GlobalRefreshResult(successful: 0, failed: 0, fromCache: 0);
    }

    state = true;

    try {
      final operations = <Future<bool>>[
        _complete(ref.refresh(airQualityProvider.future)),
        _complete(ref.refresh(airQualityHistoryProvider.future)),
        _complete(ref.refresh(forecastProvider.future)),
      ];

      final results = await Future.wait(operations);

      final statuses = ref.read(cacheStatusProvider);
      const keys = ['home', 'history', 'forecast'];

      var successful = 0;
      var failed = 0;
      var fromCache = 0;

      for (var index = 0; index < results.length; index++) {
        if (results[index]) {
          successful++;

          if (statuses[keys[index]]?.fromCache == true) {
            fromCache++;
          }
        } else {
          failed++;
        }
      }

      return GlobalRefreshResult(
        successful: successful,
        failed: failed,
        fromCache: fromCache,
      );
    } finally {
      state = false;
    }
  }

  Future<bool> _complete(Future<Object?> operation) async {
    try {
      await operation;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final globalRefreshProvider = NotifierProvider<GlobalRefreshController, bool>(
  GlobalRefreshController.new,
);
