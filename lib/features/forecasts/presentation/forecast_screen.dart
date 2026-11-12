import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/qualidade_ar_br.dart';
import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../domain/forecast_analysis.dart';
import '../providers/forecast_provider.dart';

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  PoluenteBr selectedPollutant = PoluenteBr.mp25;
  int selectedHorizon = 24;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final state = ref.watch(forecastProvider);
    final city = ref.watch(selectedCityProvider).asData?.value;
    final statuses = ref.watch(cacheStatusProvider);

    final cacheStatus = city == null
        ? null
        : statuses[EnvironmentCacheKeys.status(city, 'forecast')];

    final fromCache = cacheStatus?.fromCache ?? false;
    final data = state.asData?.value;
    final loading = state.isLoading;

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
                _ForecastHero(
                  cityName: city?.name,
                  cityState: city?.state,
                  referenceTime: loading ? null : data?.referenceTime,
                  fromCache: fromCache && !loading,
                  loading: loading,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('qualidade-ar');
                    }
                  },
                  onRefresh: loading
                      ? null
                      : () => ref.invalidate(forecastProvider),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'PROJEÇÕES AMBIENTAIS',
                        title: 'Explore o futuro do ar',
                        description:
                            'Selecione o poluente e o período '
                            'para analisar as tendências previstas.',
                      ),
                      const SizedBox(height: 23),
                      if (loading || city == null)
                        const _ForecastStatus(
                          icon: Icons.hourglass_top_outlined,
                          title: 'Consultando previsões',
                          description:
                              'Preparando os cenários ambientais '
                              'da cidade monitorada.',
                          loading: true,
                        )
                      else if (state.hasError && data == null)
                        _ForecastStatus(
                          icon: Icons.wifi_off_outlined,
                          title: 'Previsões indisponíveis',
                          description:
                              'Não foi possível consultar as '
                              'projeções nem recuperar uma cópia '
                              'armazenada.',
                          onRetry: () => ref.invalidate(forecastProvider),
                        )
                      else if (data == null)
                        const _ForecastStatus(
                          icon: Icons.cloud_off_outlined,
                          title: 'Sem previsões disponíveis',
                          description:
                              'Não encontramos informações '
                              'para apresentar neste momento.',
                        )
                      else ...[
                        if (fromCache) ...[
                          const _InformationBanner(
                            icon: Icons.storage_outlined,
                            title: 'Previsão armazenada',
                            description:
                                'Estas informações foram recuperadas '
                                'do cache local. Não representam '
                                'uma consulta em tempo real. '
                                'A referência temporal deve ser '
                                'considerada antes de interpretá-las.',
                          ),
                          const SizedBox(height: 18),
                        ],
                        Text(
                          'Poluente em análise',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: PoluenteBr.values.map((pollutant) {
                            return _SelectionChip(
                              label: _name(pollutant),
                              selected: selectedPollutant == pollutant,
                              onSelected: () {
                                setState(() {
                                  selectedPollutant = pollutant;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Horizonte da previsão',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [24, 48, 72].map((hours) {
                            return _SelectionChip(
                              label: '$hours horas',
                              selected: selectedHorizon == hours,
                              onSelected: () {
                                setState(() {
                                  selectedHorizon = hours;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 25),
                        _buildAnalysis(data, city.name),
                      ],
                      const SizedBox(height: 25),
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

  Widget _buildAnalysis(dynamic data, String cityName) {
    final points = ForecastAnalysis.calculate(
      data,
      selectedPollutant,
      selectedHorizon,
    );

    final current = ForecastAnalysis.rollingAverage(
      data,
      selectedPollutant,
      data.referenceTime,
    );

    final peak = ForecastAnalysis.peak(points);
    final daily = ForecastAnalysis.dailyPeaks(points);
    final window = QualidadeArBr.janelaHoras(selectedPollutant);
    final quality = peak?.classification;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScenarioCard(
          pollutant: _name(selectedPollutant),
          window: window,
          horizon: selectedHorizon,
          peak: peak,
          quality: quality,
          cityName: cityName,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ForecastMetric(
                icon: Icons.schedule_outlined,
                title: 'Média de referência',
                value: _number(current),
                subtitle: 'µg/m³ • $window h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ForecastMetric(
                icon: Icons.trending_up_rounded,
                title: 'Maior média futura',
                value: _number(peak?.average),
                subtitle: 'µg/m³ • $window h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _ForecastChartCard(
          points: points,
          pollutant: _name(selectedPollutant),
          window: window,
          cityName: cityName,
        ),
        const SizedBox(height: 29),
        _SectionHeading(
          eyebrow: 'VISÃO POR DIA',
          title: 'Resumo diário',
          description:
              'Maiores médias móveis previstas em cada dia '
              'no horário local de $cityName.',
        ),
        const SizedBox(height: 16),
        if (daily.isEmpty)
          const _ForecastStatus(
            icon: Icons.event_busy_outlined,
            title: 'Sem médias disponíveis',
            description:
                'Não há dados suficientes para '
                'calcular o resumo diário.',
          )
        else
          for (final point in daily) ...[
            _DailyForecastCard(point: point, cityName: cityName),
            const SizedBox(height: 11),
          ],
        const SizedBox(height: 13),
        _InformationBanner(
          icon: Icons.insights_outlined,
          title: 'Interpretação do cenário',
          description: peak == null || quality == null
              ? 'Não há médias futuras suficientes '
                    'para identificar períodos de atenção '
                    'com segurança.'
              : quality == FaixaQualidadeAr.boa
              ? 'As médias válidas disponíveis '
                    'permanecem na faixa Boa '
                    'no período selecionado. '
                    'Isso não garante que as condições '
                    'locais sejam iguais às previstas.'
              : 'Possível período de atenção '
                    'em ${_formatDate(peak.time)}, '
                    'no horário local de $cityName. '
                    'A média prevista de '
                    '${_name(selectedPollutant)} '
                    'atinge a faixa ${quality.nome}. '
                    'Consulte dados oficiais '
                    'antes de tomar decisões.',
        ),
        const SizedBox(height: 13),
        const _InformationBanner(
          icon: Icons.shield_outlined,
          title: 'Limitações da previsão',
          description:
              'A confiabilidade não foi quantificada. '
              'O CAMS Global possui resolução espacial '
              'aproximada de 45 km. Emissões locais, '
              'condições meteorológicas e outras '
              'variações podem alterar os resultados. '
              'As projeções não substituem '
              'informações de órgãos oficiais.',
        ),
      ],
    );
  }
}

class _ForecastHero extends StatelessWidget {
  final String? cityName;
  final String? cityState;
  final DateTime? referenceTime;
  final bool fromCache;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const _ForecastHero({
    required this.cityName,
    required this.cityState,
    required this.referenceTime,
    required this.fromCache,
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
              child: CustomPaint(painter: _ForecastAtmospherePainter()),
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
                        tooltip: 'Atualizar previsões',
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
                                size: 21,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 37),
                const Row(
                  children: [
                    Icon(Icons.circle, color: AppColors.breeze, size: 7),
                    SizedBox(width: 9),
                    Text(
                      'PROJEÇÕES ATMOSFÉRICAS',
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
                  'O ar nas\npróximas horas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Antecipe tendências e acompanhe '
                  'cenários ambientais estimados '
                  'para sua cidade.',
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
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            fromCache
                                ? Icons.storage_outlined
                                : Icons.schedule_outlined,
                            color: AppColors.breeze,
                            size: 17,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              loading
                                  ? 'Consultando previsões...'
                                  : referenceTime == null
                                  ? 'Aguardando dados de previsão.'
                                  : 'Referência: '
                                        '${_formatDate(referenceTime!)}\n'
                                        'Horário local de ${cityName ?? 'cidade monitorada'}'
                                        '${fromCache ? ' • Dados armazenados' : ''}',
                              style: const TextStyle(
                                color: Color(0xFFE3F1EE),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
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
                              'Projeções de modelos atmosféricos, '
                              'não medições ou alertas oficiais '
                              'da CETESB.',
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

class _ForecastAtmospherePainter extends CustomPainter {
  const _ForecastAtmospherePainter();

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

class _SelectionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _SelectionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: colors.surface,
      selectedColor: colors.primary,
      side: BorderSide(color: selected ? colors.primary : colors.border),
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      onSelected: (_) => onSelected(),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String pollutant;
  final int window;
  final int horizon;
  final ForecastPoint? peak;
  final FaixaQualidadeAr? quality;
  final String cityName;

  const _ScenarioCard({
    required this.pollutant,
    required this.window,
    required this.horizon,
    required this.peak,
    required this.quality,
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
            const Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  color: AppColors.breeze,
                  size: 19,
                ),
                SizedBox(width: 9),
                Text(
                  'CENÁRIO AMBIENTAL',
                  style: TextStyle(
                    color: AppColors.breeze,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19),
            Text(
              pollutant,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Maior média móvel prevista '
              'em $horizon horas • Janela de $window h',
              style: const TextStyle(
                color: AppColors.mist,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 23),
            const Text(
              'MAIOR MÉDIA PREVISTA',
              style: TextStyle(
                color: AppColors.breeze,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 10,
              children: [
                Text(
                  _number(peak?.average),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 49,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    height: 1.06,
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
            if (quality == null)
              const Text(
                'Dados insuficientes para classificação.',
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _qualityColor(quality!, AppThemePalette.light),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Faixa estimada: ${quality!.nome}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 21),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    color: AppColors.breeze,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      peak == null
                          ? 'Horário do pico indisponível.'
                          : 'Pico previsto: ${_formatDate(peak!.time)}\n'
                                'Horário local de $cityName',
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
              'Classificação estimada a partir de '
              'médias móveis e faixas brasileiras. '
              'Não representa medição oficial '
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

class _ForecastMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _ForecastMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 152),
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 27,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ForecastChartCard extends StatelessWidget {
  final List<ForecastPoint> points;
  final String pollutant;
  final int window;
  final String cityName;

  const _ForecastChartCard({
    required this.points,
    required this.pollutant,
    required this.window,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final validCount = points.where((point) => point.average != null).length;

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
            'Evolução prevista',
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$pollutant • Média móvel de $window h • µg/m³',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Horários locais de $cityName',
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 25),
          if (validCount >= 2)
            SizedBox(height: 240, child: _ForecastChart(points: points))
          else
            SizedBox(
              height: 165,
              child: Center(
                child: Text(
                  'Dados insuficientes para gerar o gráfico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.info, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cada ponto representa uma média móvel '
                  'calculada com dados horários previstos.',
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

class _ForecastChart extends StatelessWidget {
  final List<ForecastPoint> points;

  const _ForecastChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final values = points.map((point) => point.average).whereType<double>();

    final maximum = values.fold<double>(
      0,
      (previous, value) => value > previous ? value : previous,
    );

    final top = maximum <= 0 ? 1.0 : maximum * 1.2;

    final spots = <FlSpot>[];

    for (var index = 0; index < points.length; index++) {
      final value = points[index].average;

      spots.add(
        value == null ? FlSpot.nullSpot : FlSpot(index.toDouble(), value),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
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
              reservedSize: 30,
              interval: 12,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index >= points.length || index % 12 != 0) {
                  return const SizedBox.shrink();
                }

                final time = points[index].time;

                return Text(
                  '${time.day}/${time.month} ${time.hour}h',
                  style: TextStyle(color: colors.textSecondary, fontSize: 9),
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

class _DailyForecastCard extends StatelessWidget {
  final ForecastPoint point;
  final String cityName;

  const _DailyForecastCard({required this.point, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final classification = point.classification;
    final color = classification == null
        ? colors.info
        : _qualityColor(classification, colors);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: colors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDay(point.time),
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Maior média: ${_number(point.average)} µg/m³',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pico às ${point.time.hour.toString().padLeft(2, '0')}:'
                  '${point.time.minute.toString().padLeft(2, '0')} '
                  '• Horário local de $cityName',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (classification != null) ...[
            const SizedBox(width: 7),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  classification.nome,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
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

class _ForecastStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool loading;
  final VoidCallback? onRetry;

  const _ForecastStatus({
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

String _name(PoluenteBr pollutant) {
  return switch (pollutant) {
    PoluenteBr.mp25 => 'MP2,5',
    PoluenteBr.mp10 => 'MP10',
    PoluenteBr.ozonio => 'Ozônio',
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

String _number(double? value) {
  return value == null ? '—' : value.toStringAsFixed(1).replaceAll('.', ',');
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month às $hour:$minute';
}

String _formatDay(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month';
}
