import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/qualidade_ar_br.dart';
import '../../../core/theme/app_theme.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../data/air_quality_history.dart';
import '../domain/air_quality_analysis.dart';
import '../providers/air_quality_history_provider.dart';

class AirQualityScreen extends ConsumerStatefulWidget {
  const AirQualityScreen({super.key});

  @override
  ConsumerState<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends ConsumerState<AirQualityScreen> {
  PoluenteBr _selectedPollutant = PoluenteBr.mp25;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final historyState = ref.watch(airQualityHistoryProvider);
    final selectedCity = ref.watch(selectedCityProvider).asData?.value;
    final history = historyState.asData?.value;

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
                _AirHero(
                  cityName: selectedCity?.name,
                  cityState: selectedCity?.state,
                  loading: historyState.isLoading,
                  onRefresh: historyState.isLoading
                      ? null
                      : () => ref.invalidate(airQualityHistoryProvider),
                  onPollutants: () => context.pushNamed('poluentes'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'ANÁLISE AMBIENTAL',
                        title: 'Entenda os indicadores',
                        description:
                            'Explore as concentrações estimadas '
                            'dos principais poluentes atmosféricos.',
                      ),
                      const SizedBox(height: 24),
                      if (historyState.isLoading && history == null)
                        const _MessageCard(
                          icon: Icons.hourglass_top_outlined,
                          title: 'Consultando o histórico',
                          description:
                              'Estamos carregando as informações '
                              'ambientais da cidade monitorada.',
                          loading: true,
                        )
                      else if (historyState.hasError && history == null)
                        _MessageCard(
                          icon: Icons.wifi_off_outlined,
                          title: 'Histórico indisponível',
                          description:
                              'Não foi possível consultar os dados '
                              'ambientais. Verifique sua conexão.',
                          onRetry: () =>
                              ref.invalidate(airQualityHistoryProvider),
                        )
                      else if (history == null || history.hours.isEmpty)
                        const _MessageCard(
                          icon: Icons.cloud_off_outlined,
                          title: 'Sem dados disponíveis',
                          description:
                              'Ainda não existem informações '
                              'suficientes para apresentar a análise.',
                        )
                      else
                        _buildDashboard(history, selectedCity?.name),
                      const SizedBox(height: 28),
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

  Widget _buildDashboard(AirQualityHistory history, String? cityName) {
    final colors = AppTheme.paletteOf(context);
    final pollutant = _selectedPollutant;

    final average = AirQualityAnalysis.referenceAverage(history, pollutant);

    final classification = AirQualityAnalysis.referenceClassification(
      history,
      pollutant,
    );

    final window = QualidadeArBr.janelaHoras(pollutant);

    final validHours = history.hours.where((hour) {
      return AirQualityAnalysis.concentration(hour, pollutant) != null;
    }).toList();

    final latestHour = validHours.isEmpty ? null : validHours.last;

    final latestValue = latestHour == null
        ? null
        : AirQualityAnalysis.concentration(latestHour, pollutant);

    final chartHours = history.hours.length > 24
        ? history.hours.sublist(history.hours.length - 24)
        : history.hours;

    final chartValidCount = chartHours.where((hour) {
      return AirQualityAnalysis.concentration(hour, pollutant) != null;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poluente em análise',
          style: TextStyle(
            color: colors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: PoluenteBr.values.map((item) {
            final selected = pollutant == item;

            return ChoiceChip(
              label: Text(_pollutantName(item)),
              selected: selected,
              showCheckmark: false,
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              side: BorderSide(
                color: selected ? colors.primary : colors.border,
              ),
              labelStyle: TextStyle(
                color: selected ? colors.onPrimary : colors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              onSelected: (_) {
                setState(() {
                  _selectedPollutant = item;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        _AverageCard(
          pollutantName: _pollutantName(pollutant),
          average: average,
          window: window,
          classification: classification,
          referenceTime: history.referenceTime,
          cityName: cityName,
        ),
        const SizedBox(height: 28),
        _HistoryCard(
          pollutantName: _pollutantName(pollutant),
          pollutant: pollutant,
          hours: chartHours,
          validCount: chartValidCount,
          cityName: cityName,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _ValueCard(
                icon: Icons.schedule_outlined,
                title: 'Última estimativa',
                value: _formatValue(latestValue),
                subtitle: 'µg/m³',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ValueCard(
                icon: Icons.analytics_outlined,
                title: 'Média $window h',
                value: _formatValue(average),
                subtitle: 'µg/m³',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _InformationBanner(
          icon: Icons.info_outline_rounded,
          title: 'Como interpretar os dados',
          description:
              'As concentrações são estimativas do CAMS Global. '
              'A classificação considera referências brasileiras '
              'e períodos específicos para cada poluente. '
              'Os resultados não representam medições oficiais '
              'da CETESB nem o índice numérico IQAr.',
        ),
        const SizedBox(height: 22),
        _NavigationCard(
          icon: Icons.insights_outlined,
          title: 'Explore os poluentes',
          description:
              'Entenda o que são MP2,5, MP10 e ozônio '
              'e como podem afetar a qualidade do ar.',
          onTap: () => context.pushNamed('poluentes'),
        ),
      ],
    );
  }
}

class _AirHero extends StatelessWidget {
  final String? cityName;
  final String? cityState;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback onPollutants;

  const _AirHero({
    required this.cityName,
    required this.cityState,
    required this.loading,
    required this.onRefresh,
    required this.onPollutants,
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
              child: CustomPaint(painter: _AirAtmospherePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 29),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: 38,
                      height: 38,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Aeris Pulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
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
                        tooltip: 'Atualizar histórico ambiental',
                        onPressed: onRefresh,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 22,
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
                      'ANÁLISE DA ATMOSFERA',
                      style: TextStyle(
                        color: AppColors.breeze,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Text(
                  'Qualidade do ar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Entenda o que está presente no ar '
                  'e como as concentrações evoluem.',
                  style: TextStyle(
                    color: Color(0xFFD3E8E5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.105),
                    borderRadius: BorderRadius.circular(21),
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
                      const SizedBox(height: 15),
                      Text(
                        cityName ?? 'Carregando localidade...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        cityState == null
                            ? 'Aguardando seleção'
                            : '$cityState • Brasil',
                        style: const TextStyle(
                          color: Color(0xFFCAE5DF),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFB7DBD5),
                            size: 17,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Fonte: Open-Meteo / CAMS Global. '
                              'Dados estimados por modelos atmosféricos.',
                              style: TextStyle(
                                color: Color(0xFFC8E1DC),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onPollutants,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.insights_outlined, size: 19),
                  label: const Text(
                    'Conheça os poluentes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

class _AirAtmospherePainter extends CustomPainter {
  const _AirAtmospherePainter();

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
        const SizedBox(height: 7),
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

class _AverageCard extends StatelessWidget {
  final String pollutantName;
  final double? average;
  final int window;
  final FaixaQualidadeAr? classification;
  final DateTime referenceTime;
  final String? cityName;

  const _AverageCard({
    required this.pollutantName,
    required this.average,
    required this.window,
    required this.classification,
    required this.referenceTime,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF071B20), Color(0xFF0B3439), Color(0xFF12434A)]
              : const [Color(0xFF073B40), AppColors.primary, Color(0xFF176D6D)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.breeze,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${pollutantName.toUpperCase()} • MÉDIA DE $window HORAS',
                    style: const TextStyle(
                      color: AppColors.breeze,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 10,
              children: [
                Text(
                  _formatValue(average),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 49,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    height: 1.05,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'µg/m³',
                    style: TextStyle(color: AppColors.mist, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            if (classification != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _qualityColor(classification!),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Faixa: ${classification!.nome}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              )
            else
              const Text(
                'Dados insuficientes para classificação.',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            const SizedBox(height: 23),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    color: AppColors.breeze,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Referência: ${_formatDate(referenceTime)}\n'
                      'Horário local de ${cityName ?? 'cidade monitorada'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Classificação estimada usando faixas brasileiras '
              'de qualidade do ar. Não representa medição oficial '
              'nem o índice numérico IQAr.',
              style: TextStyle(
                color: Color(0xFFC8E1DC),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String pollutantName;
  final PoluenteBr pollutant;
  final List<AirQualityHour> hours;
  final int validCount;
  final String? cityName;

  const _HistoryCard({
    required this.pollutantName,
    required this.pollutant,
    required this.hours,
    required this.validCount,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 19, 17, 17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolução nas últimas 24 horas',
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$pollutantName • Concentração em µg/m³',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Horários locais de ${cityName ?? 'cidade monitorada'}',
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 25),
          if (validCount >= 2)
            SizedBox(
              height: 240,
              child: _AirChart(hours: hours, pollutant: pollutant),
            )
          else
            SizedBox(
              height: 170,
              child: Center(
                child: Text(
                  'Histórico insuficiente para gerar o gráfico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.info, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Série horária modelada. '
                  'Não representa sensores locais.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirChart extends StatelessWidget {
  final List<AirQualityHour> hours;
  final PoluenteBr pollutant;

  const _AirChart({required this.hours, required this.pollutant});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    final values = hours
        .map((hour) => AirQualityAnalysis.concentration(hour, pollutant))
        .whereType<double>()
        .toList();

    final highest = values.fold<double>(
      0,
      (previous, value) => value > previous ? value : previous,
    );

    final maxY = highest <= 0 ? 1.0 : highest * 1.2;

    final spots = <FlSpot>[];

    for (var index = 0; index < hours.length; index++) {
      final value = AirQualityAnalysis.concentration(hours[index], pollutant);

      spots.add(
        value == null ? FlSpot.nullSpot : FlSpot(index.toDouble(), value),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (hours.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
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
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(maxY < 10 ? 1 : 0),
                style: TextStyle(fontSize: 10, color: colors.textSecondary),
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
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: colors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colors.breeze.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _ValueCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: colors.primary, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
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

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool loading;
  final VoidCallback? onRetry;

  const _MessageCard({
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

Color _qualityColor(FaixaQualidadeAr quality) {
  return switch (quality) {
    FaixaQualidadeAr.boa => AppColors.good,
    FaixaQualidadeAr.moderada => AppColors.moderate,
    FaixaQualidadeAr.ruim => AppColors.poor,
    FaixaQualidadeAr.muitoRuim => AppColors.veryPoor,
    FaixaQualidadeAr.pessima => AppColors.severe,
  };
}

String _formatValue(double? value) {
  return value == null ? '—' : value.toStringAsFixed(1).replaceAll('.', ',');
}

String _formatDate(DateTime time) {
  final day = time.day.toString().padLeft(2, '0');
  final month = time.month.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$day/$month às $hour:$minute';
}
