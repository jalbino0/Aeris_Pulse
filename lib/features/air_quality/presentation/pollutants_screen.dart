import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/qualidade_ar_br.dart';
import '../../../core/theme/app_theme.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../data/air_quality_history.dart';
import '../domain/air_quality_analysis.dart';
import '../domain/pollutant_statistics.dart';
import '../providers/air_quality_history_provider.dart';

class PollutantsScreen extends ConsumerWidget {
  const PollutantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.paletteOf(context);
    final state = ref.watch(airQualityHistoryProvider);
    final history = state.asData?.value;
    final selectedCity = ref.watch(selectedCityProvider).asData?.value;

    void refresh() {
      ref.invalidate(airQualityHistoryProvider);
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _PollutantsHero(
                  cityName: selectedCity?.name,
                  cityState: selectedCity?.state,
                  referenceTime: history?.referenceTime,
                  loading: state.isLoading,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('qualidade-ar');
                    }
                  },
                  onRefresh: state.isLoading ? null : refresh,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'MONITORAMENTO ATMOSFÉRICO',
                        title: 'Poluentes em detalhe',
                        description:
                            'Acompanhe concentrações, variações '
                            'e tendências dos principais poluentes '
                            'presentes na atmosfera.',
                      ),
                      const SizedBox(height: 24),
                      if (state.isLoading && history == null)
                        const _FeedbackPanel(
                          icon: Icons.hourglass_top_outlined,
                          title: 'Consultando os poluentes',
                          description:
                              'Carregando as séries ambientais '
                              'da cidade monitorada.',
                          loading: true,
                        )
                      else if (state.hasError && history == null)
                        _FeedbackPanel(
                          icon: Icons.wifi_off_outlined,
                          title: 'Dados indisponíveis',
                          description:
                              'Não foi possível consultar os dados '
                              'dos poluentes. Verifique a conexão.',
                          onRetry: refresh,
                        )
                      else if (history == null || history.hours.isEmpty)
                        const _FeedbackPanel(
                          icon: Icons.cloud_off_outlined,
                          title: 'Nenhum registro disponível',
                          description:
                              'Ainda não há informações suficientes '
                              'para apresentar os poluentes.',
                        )
                      else ...[
                        const _SectionLabel(
                          label: 'CONCENTRAÇÕES E TENDÊNCIAS',
                        ),
                        const SizedBox(height: 14),
                        for (final pollutant in PoluenteBr.values) ...[
                          _PollutantPanel(
                            history: history,
                            pollutant: pollutant,
                            cityName: selectedCity?.name,
                          ),
                          const SizedBox(height: 17),
                        ],
                        const SizedBox(height: 9),
                        const _InformationBanner(
                          icon: Icons.info_outline_rounded,
                          title: 'Como interpretar os resultados',
                          description:
                              'Cada poluente possui limites '
                              'e períodos de referência próprios. '
                              'Não compare concentrações brutas '
                              'como se representassem o mesmo risco. '
                              'As classificações são estimativas '
                              'baseadas em referências brasileiras, '
                              'não valores oficiais de IQAr.',
                        ),
                      ],
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          'Aeris Pulse • Inteligência atmosférica',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PollutantsHero extends StatelessWidget {
  final String? cityName;
  final String? cityState;
  final DateTime? referenceTime;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const _PollutantsHero({
    required this.cityName,
    required this.cityState,
    required this.referenceTime,
    required this.loading,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF071B20), Color(0xFF0B3439), Color(0xFF12434A)]
              : const [Color(0xFF073B40), AppColors.primary, Color(0xFF0F6466)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PollutantsAtmospherePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 15, 20, 29),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Voltar para qualidade do ar',
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: 35,
                      height: 35,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Aeris Pulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: IconButton(
                        tooltip: 'Atualizar concentrações',
                        onPressed: onRefresh,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 37),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.breeze),
                    SizedBox(width: 9),
                    Text(
                      'ANÁLISE DOS POLUENTES',
                      style: TextStyle(
                        color: AppColors.breeze,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Text(
                  'O que existe\nno seu ar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Entenda as partículas e os gases '
                  'que monitoramos, suas concentrações '
                  'e como evoluem ao longo do tempo.',
                  style: TextStyle(
                    color: Color(0xFFD3E8E5),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.105),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.breeze,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CIDADE MONITORADA',
                            style: TextStyle(
                              color: AppColors.breeze,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cityName ?? 'Carregando localidade...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cityState == null
                            ? 'Aguardando seleção'
                            : '$cityState • Brasil',
                        style: const TextStyle(
                          color: Color(0xFFCAE5DF),
                          fontSize: 12,
                        ),
                      ),
                      if (referenceTime != null) ...[
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: AppColors.breeze,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Referência: ${_formattedDate(referenceTime!)}\n'
                                'Horário local de ${cityName ?? 'cidade monitorada'}',
                                style: const TextStyle(
                                  color: Color(0xFFE3F1EE),
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFB7DBD5),
                            size: 16,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Fonte: Open-Meteo / CAMS Global. '
                              'Concentrações modeladas em µg/m³, '
                              'não medições oficiais da CETESB.',
                              style: TextStyle(
                                color: Color(0xFFC8E1DC),
                                fontSize: 11,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PollutantsAtmospherePainter extends CustomPainter {
  const _PollutantsAtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    for (var index = 0; index < 6; index++) {
      final shift = index * 22.0;

      final path = Path()
        ..moveTo(width * 0.38, -60 + shift)
        ..cubicTo(
          width * 0.68,
          height * 0.08 + shift,
          width * 0.58,
          height * 0.38 + shift,
          width + 60,
          height * 0.18 + shift,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.035 + index * 0.009)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    final center = Offset(width * 0.91, height * 0.13);

    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(
        center,
        50 + index * 25.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.045)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: colors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.65,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Text(
      label,
      style: TextStyle(
        color: colors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PollutantPanel extends StatelessWidget {
  final AirQualityHistory history;
  final PoluenteBr pollutant;
  final String? cityName;

  const _PollutantPanel({
    required this.history,
    required this.pollutant,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final statistics = PollutantStatistics.fromHistory(history, pollutant);

    final window = QualidadeArBr.janelaHoras(pollutant);
    final classification = statistics.classification;
    final difference = statistics.hourlyChange;
    final color = _pollutantColor(pollutant, colors);

    final chartHours = history.hours.length > 24
        ? history.hours.sublist(history.hours.length - 24)
        : history.hours;

    final chartValidSamples = chartHours.where((hour) {
      return AirQualityAnalysis.concentration(hour, pollutant) != null;
    }).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_pollutantIcon(pollutant), color: color, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pollutantName(pollutant),
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pollutantDescription(pollutant),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '$window h',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'CONCENTRAÇÃO ESTIMADA',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 9,
            children: [
              Text(
                _formatValue(statistics.latest),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 43,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.3,
                  height: 1.1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'µg/m³',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ChangeIndicator(difference: difference),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evolução nas últimas 24 horas',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'HISTÓRICO',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Horários locais de ${cityName ?? 'cidade monitorada'}',
            style: TextStyle(color: colors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 19),
          if (chartValidSamples >= 2)
            SizedBox(
              height: 187,
              child: _PollutantLineChart(
                hours: chartHours,
                pollutant: pollutant,
                color: color,
              ),
            )
          else
            SizedBox(
              height: 115,
              child: Center(
                child: Text(
                  'Dados insuficientes para gerar o gráfico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Série horária modelada • Não representa sensores locais',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 21),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 21),
          Row(
            children: [
              Expanded(
                child: _NumberDetail(
                  label: 'Mínima (24h)',
                  value: _formatValue(statistics.minimum),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberDetail(
                  label: 'Máxima (24h)',
                  value: _formatValue(statistics.maximum),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberDetail(
                  label: 'Média ($window h)',
                  value: _formatValue(statistics.referenceAverage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: classification == null
                  ? colors.infoBackground
                  : _qualityColor(
                      classification,
                      colors,
                    ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  classification == null
                      ? Icons.info_outline
                      : Icons.verified_outlined,
                  color: classification == null
                      ? colors.info
                      : _qualityColor(classification, colors),
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    classification == null
                        ? 'Dados insuficientes para classificação.'
                        : 'Faixa brasileira estimada: '
                              '${classification.nome}',
                    style: TextStyle(
                      color: classification == null
                          ? colors.text
                          : _qualityColor(classification, colors),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${statistics.validSamples} de '
            '${history.hours.length} horários com dados válidos. '
            'A média de referência exige $window '
            'horas consecutivas.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeIndicator extends StatelessWidget {
  final double? difference;

  const _ChangeIndicator({required this.difference});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final rising = difference != null && difference! > 0;
    final falling = difference != null && difference! < 0;

    final color = rising
        ? colors.poor
        : falling
        ? colors.good
        : colors.textSecondary;

    final icon = rising
        ? Icons.trending_up_rounded
        : falling
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    final text = difference == null
        ? 'Variação horária indisponível'
        : difference == 0
        ? 'Estável em relação à hora anterior'
        : '${_formatValue(difference!.abs())} µg/m³ '
              '${rising ? 'acima' : 'abaixo'} da hora anterior';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PollutantLineChart extends StatelessWidget {
  final List<AirQualityHour> hours;
  final PoluenteBr pollutant;
  final Color color;

  const _PollutantLineChart({
    required this.hours,
    required this.pollutant,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final points = <FlSpot>[];
    var peak = 0.0;

    for (var index = 0; index < hours.length; index++) {
      final value = AirQualityAnalysis.concentration(hours[index], pollutant);

      if (value == null) {
        points.add(FlSpot.nullSpot);
      } else {
        points.add(FlSpot(index.toDouble(), value));

        if (value > peak) {
          peak = value;
        }
      }
    }

    final top = peak <= 0 ? 1.0 : peak * 1.2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (hours.length - 1).toDouble(),
        minY: 0,
        maxY: top,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colors.border, strokeWidth: 0.8),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: top / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(top < 10 ? 1 : 0),
                style: TextStyle(color: colors.textSecondary, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 6,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= hours.length || index % 6 != 0) {
                  return const SizedBox.shrink();
                }

                return Text(
                  '${hours[index].time.hour}h',
                  style: TextStyle(color: colors.textSecondary, fontSize: 10),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberDetail extends StatelessWidget {
  final String label;
  final String value;

  const _NumberDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 10),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            color: colors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'µg/m³',
          style: TextStyle(color: colors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

class _InformationBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InformationBanner({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool loading;
  final VoidCallback? onRetry;

  const _FeedbackPanel({
    required this.icon,
    required this.title,
    required this.description,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          if (loading)
            CircularProgressIndicator(color: colors.primary)
          else
            Icon(icon, color: colors.primary, size: 35),
          const SizedBox(height: 17),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _pollutantName(PoluenteBr pollutant) {
  return switch (pollutant) {
    PoluenteBr.mp25 => 'MP2,5',
    PoluenteBr.mp10 => 'MP10',
    PoluenteBr.ozonio => 'Ozônio',
  };
}

String _pollutantDescription(PoluenteBr pollutant) {
  return switch (pollutant) {
    PoluenteBr.mp25 => 'Partículas finas • média de 24 h',
    PoluenteBr.mp10 => 'Partículas inaláveis • média de 24 h',
    PoluenteBr.ozonio => 'O₃ • média de 8 h',
  };
}

IconData _pollutantIcon(PoluenteBr pollutant) {
  return switch (pollutant) {
    PoluenteBr.mp25 => Icons.grain_rounded,
    PoluenteBr.mp10 => Icons.blur_on_rounded,
    PoluenteBr.ozonio => Icons.bubble_chart_outlined,
  };
}

Color _pollutantColor(PoluenteBr pollutant, AppThemePalette colors) {
  return switch (pollutant) {
    PoluenteBr.mp25 => colors.primary,
    PoluenteBr.mp10 => colors.info,
    PoluenteBr.ozonio => colors.moderate,
  };
}

Color _qualityColor(FaixaQualidadeAr quality, AppThemePalette colors) {
  return switch (quality) {
    FaixaQualidadeAr.boa => colors.good,
    FaixaQualidadeAr.moderada => colors.moderate,
    FaixaQualidadeAr.ruim => colors.poor,
    FaixaQualidadeAr.muitoRuim => colors.veryPoor,
    FaixaQualidadeAr.pessima => colors.severe,
  };
}

String _formatValue(double? value) {
  return value == null ? '—' : value.toStringAsFixed(1).replaceAll('.', ',');
}

String _formattedDate(DateTime time) {
  final day = time.day.toString().padLeft(2, '0');
  final month = time.month.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$day/$month às $hour:$minute';
}
