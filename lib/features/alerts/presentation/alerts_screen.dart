import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/network/environment_cache_keys.dart';
import '../../../core/providers/cache_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../forecasts/data/forecast_data.dart';
import '../../forecasts/providers/forecast_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../domain/alert_engine.dart';
import '../domain/safe_alert_engine.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool _demonstration = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final forecastState = ref.watch(forecastProvider);
    final city = ref.watch(selectedCityProvider).asData?.value;
    final cacheStatuses = ref.watch(cacheStatusProvider);

    final fromCache = city == null
        ? false
        : cacheStatuses[EnvironmentCacheKeys.status(city, 'forecast')]
                  ?.fromCache ??
              false;

    final ForecastData? forecast = forecastState.asData?.value;

    final SafeAlertResult? report = _demonstration
        ? SafeAlertEngine.evaluate(
            DemonstrationForecast.create(),
            demonstration: true,
          )
        : forecastState.isLoading || city == null || forecast == null
        ? null
        : SafeAlertEngine.evaluate(forecast, fromCache: fromCache);

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
                _AlertsHero(
                  title: 'Fique um passo\nà frente.',
                  subtitle:
                      'Antecipe possíveis condições de atenção '
                      'com análises ambientais responsáveis.',
                  eyebrow: 'MONITORAMENTO PREDITIVO',
                  cityName: city?.name,
                  cityState: city?.state,
                  demonstration: _demonstration,
                  loading: forecastState.isLoading,
                  onRefresh: forecastState.isLoading
                      ? null
                      : () => ref.invalidate(forecastProvider),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'CENTRAL DE ALERTAS',
                        title: 'Análise preditiva',
                        description:
                            'Acompanhe projeções do modelo atmosférico '
                            'ou explore um cenário demonstrativo.',
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Modo de análise',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: 'Previsão',
                              icon: Icons.cloud_outlined,
                              selected: !_demonstration,
                              onPressed: () {
                                setState(() {
                                  _demonstration = false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _ModeButton(
                              label: 'Demonstração',
                              icon: Icons.science_outlined,
                              selected: _demonstration,
                              onPressed: () {
                                setState(() {
                                  _demonstration = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_demonstration)
                        const _InformationCard(
                          icon: Icons.science_outlined,
                          title: 'Cenário demonstrativo',
                          description:
                              'As concentrações e os alertas '
                              'deste modo são fictícios. '
                              'Eles não representam condições '
                              'ambientais reais.',
                        )
                      else if (forecastState.isLoading || city == null)
                        const _InformationCard(
                          icon: Icons.hourglass_top_outlined,
                          title: 'Consultando previsões',
                          description:
                              'Verificando as informações ambientais '
                              'da cidade monitorada.',
                          loading: true,
                        )
                      else if (forecastState.hasError && forecast == null)
                        _InformationCard(
                          icon: Icons.wifi_off_outlined,
                          title: 'Previsão indisponível',
                          description:
                              'Não foi possível consultar uma previsão '
                              'nem recuperar uma cópia válida.',
                          onRetry: () => ref.invalidate(forecastProvider),
                        )
                      else if (forecast == null)
                        const _InformationCard(
                          icon: Icons.cloud_off_outlined,
                          title: 'Dados indisponíveis',
                          description:
                              'Ainda não existem dados válidos '
                              'para realizar esta análise.',
                        ),
                      if (report != null) ...[
                        if (report.fromCache || !report.isReady) ...[
                          const SizedBox(height: 13),
                          _InformationCard(
                            icon: !report.isReady
                                ? Icons.warning_amber_outlined
                                : Icons.storage_outlined,
                            title: report.statusTitle,
                            description: report.statusDescription,
                          ),
                        ],
                        const SizedBox(height: 29),
                        _SectionHeading(
                          eyebrow: 'RESULTADOS',
                          title: report.isReady
                              ? 'Condições previstas'
                              : 'Situação da previsão',
                          description:
                              'Referência: ${_formatWallTime(report.sourceTime)}\n'
                              '${_timeContext(city?.name, _demonstration)}',
                        ),
                        if (report.isReady) ...[
                          const SizedBox(height: 19),
                          _AnalysisTransparencyCard(report: report),
                        ],
                        const SizedBox(height: 19),
                        if (!report.isReady)
                          const _InformationCard(
                            icon: Icons.event_busy_outlined,
                            title: 'Nenhum alerta futuro emitido',
                            description:
                                'A análise foi bloqueada por segurança. '
                                'Atualize as previsões para obter '
                                'dados adequados.',
                          )
                        else if (report.alerts.isEmpty)
                          const _EmptyAlertsCard()
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Alertas identificados',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _StatusPill(
                                label:
                                    '${report.alerts.length} ${report.alerts.length == 1 ? 'alerta' : 'alertas'}',
                                color: colors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          for (final alert in report.alerts) ...[
                            _AlertCard(
                              alert: alert,
                              fromCache: report.fromCache,
                              demonstration: _demonstration,
                              cityName: city?.name,
                            ),
                            const SizedBox(height: 13),
                          ],
                          _SocialImpactCard(alerts: report.alerts),
                        ],
                      ],
                      const SizedBox(height: 25),
                      const _InformationCard(
                        icon: Icons.shield_outlined,
                        title: 'A decisão final é humana',
                        description:
                            'Os alertas utilizam projeções do '
                            'Open-Meteo/CAMS e não representam '
                            'avisos oficiais da CETESB. '
                            'Eles apoiam o planejamento, '
                            'mas não substituem a avaliação '
                            'humana ou orientações de autoridades '
                            'ambientais e serviços de saúde.',
                      ),
                      const SizedBox(height: 29),
                      const _Footer(),
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

class AlertDetailsScreen extends ConsumerWidget {
  final String pollutantId;
  final bool demonstration;

  const AlertDetailsScreen({
    super.key,
    required this.pollutantId,
    required this.demonstration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.paletteOf(context);
    final forecastState = demonstration ? null : ref.watch(forecastProvider);

    final city = ref.watch(selectedCityProvider).asData?.value;
    final statuses = ref.watch(cacheStatusProvider);

    final fromCache = city == null
        ? false
        : statuses[EnvironmentCacheKeys.status(city, 'forecast')]?.fromCache ??
              false;

    final forecast = forecastState?.asData?.value;

    final SafeAlertResult? report = demonstration
        ? SafeAlertEngine.evaluate(
            DemonstrationForecast.create(),
            demonstration: true,
          )
        : forecastState?.isLoading == true || city == null || forecast == null
        ? null
        : SafeAlertEngine.evaluate(forecast, fromCache: fromCache);

    PredictiveAlert? selectedAlert;

    if (report != null && report.isReady) {
      for (final alert in report.alerts) {
        if (alert.id == pollutantId) {
          selectedAlert = alert;
          break;
        }
      }
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
                _AlertsHero(
                  title: 'Entenda\no alerta.',
                  subtitle:
                      'Conheça os indicadores, as evidências '
                      'e as limitações desta análise.',
                  eyebrow: 'DETALHES DA ANÁLISE',
                  cityName: city?.name,
                  cityState: city?.state,
                  demonstration: demonstration,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('alertas');
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'INFORMAÇÕES DO ALERTA',
                        title: 'Análise detalhada',
                        description:
                            'Entenda como o sistema identificou '
                            'uma possível condição de atenção.',
                      ),
                      const SizedBox(height: 23),
                      if (report == null)
                        _InformationCard(
                          icon: forecastState?.hasError == true
                              ? Icons.wifi_off_outlined
                              : Icons.hourglass_top_outlined,
                          title: forecastState?.hasError == true
                              ? 'Previsão indisponível'
                              : 'Carregando análise',
                          description:
                              'Não foi possível apresentar '
                              'os detalhes deste alerta '
                              'neste momento.',
                          loading: forecastState?.isLoading == true,
                        )
                      else if (!report.isReady)
                        _InformationCard(
                          icon: Icons.event_busy_outlined,
                          title: report.statusTitle,
                          description:
                              '${report.statusDescription} '
                              'Este alerta não será apresentado '
                              'como uma previsão futura válida.',
                        )
                      else if (selectedAlert == null)
                        const _InformationCard(
                          icon: Icons.info_outline_rounded,
                          title: 'Alerta não disponível',
                          description:
                              'Não existe mais um alerta futuro '
                              'válido para este poluente '
                              'na previsão atual.',
                        )
                      else ...[
                        _AlertSpotlight(alert: selectedAlert),
                        const SizedBox(height: 19),
                        if (demonstration)
                          const _InformationCard(
                            icon: Icons.science_outlined,
                            title: 'Simulação',
                            description:
                                'Os valores apresentados '
                                'são exclusivamente ilustrativos.',
                          )
                        else if (report.fromCache)
                          const _InformationCard(
                            icon: Icons.storage_outlined,
                            title: 'Prévia offline',
                            description:
                                'O resultado utiliza uma previsão '
                                'armazenada localmente. '
                                'É necessário confirmar '
                                'as condições com dados recentes.',
                          ),
                        const SizedBox(height: 29),
                        const _SectionHeading(
                          eyebrow: 'DADOS DA PROJEÇÃO',
                          title: 'Indicadores do alerta',
                          description:
                              'Métricas e informações utilizadas '
                              'para identificar a condição prevista.',
                        ),
                        const SizedBox(height: 17),
                        _DetailRow(
                          icon: Icons.show_chart_rounded,
                          label: 'Maior média móvel prevista',
                          value:
                              '${_formatNumber(selectedAlert.peakAverage)} µg/m³',
                        ),
                        _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Período da média',
                          value: '${selectedAlert.referenceHours} horas',
                        ),
                        _DetailRow(
                          icon: Icons.access_time_outlined,
                          label: 'Horário do pico estimado',
                          value:
                              '${_formatWallTime(selectedAlert.peakTime)}\n'
                              '${_timeContext(city?.name, demonstration)}',
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Referência da previsão',
                          value:
                              '${_formatWallTime(selectedAlert.referenceTime)}\n'
                              '${_timeContext(city?.name, demonstration)}',
                        ),
                        _DetailRow(
                          icon: Icons.analytics_outlined,
                          label: 'Pontos considerados',
                          value:
                              '${selectedAlert.availablePoints} '
                              'de ${selectedAlert.expectedPoints}',
                        ),
                        _DetailRow(
                          icon: Icons.data_usage_outlined,
                          label: 'Cobertura das médias',
                          value: selectedAlert.coverageLabel,
                        ),
                        _DetailRow(
                          icon: Icons.fact_check_outlined,
                          label: 'Confiança da previsão',
                          value: selectedAlert.confidenceLevel,
                        ),
                        _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Antecedência potencial',
                          value: selectedAlert.leadTimeLabel,
                        ),
                        const SizedBox(height: 20),
                        const _SectionHeading(
                          eyebrow: 'TRANSPARÊNCIA',
                          title: 'Por que este alerta?',
                          description:
                              'Evidências, confiança e limitações '
                              'apresentadas de maneira clara.',
                        ),
                        const SizedBox(height: 17),
                        _InformationCard(
                          icon: Icons.insights_outlined,
                          title: 'Evidências do alerta',
                          description: selectedAlert.evidenceSummary,
                        ),
                        const SizedBox(height: 12),
                        _InformationCard(
                          icon: Icons.show_chart_rounded,
                          title: 'Variação prevista',
                          description: selectedAlert.variationSummary,
                        ),
                        const SizedBox(height: 12),
                        _InformationCard(
                          icon: Icons.fact_check_outlined,
                          title: 'Confiança e cobertura',
                          description: selectedAlert.confidenceExplanation,
                        ),
                        const SizedBox(height: 12),
                        const _InformationCard(
                          icon: Icons.info_outline_rounded,
                          title: 'Como interpretar',
                          description:
                              'A classificação considera médias '
                              'móveis e faixas brasileiras '
                              'específicas para cada poluente. '
                              'A concentração em µg/m³ '
                              'não corresponde diretamente '
                              'ao índice numérico IQAr.',
                        ),
                        const SizedBox(height: 29),
                        const _SectionHeading(
                          eyebrow: 'IMPACTO SOCIAL',
                          title: 'Planejamento preventivo',
                          description:
                              'Um indicador de antecedência '
                              'potencial para apoiar decisões.',
                        ),
                        const SizedBox(height: 16),
                        _BenefitCard(alert: selectedAlert),
                        const SizedBox(height: 13),
                        _InformationCard(
                          icon: Icons.shield_outlined,
                          title: 'Limitações da análise',
                          description: selectedAlert.limitations,
                        ),
                        const SizedBox(height: 13),
                        _InformationCard(
                          icon: Icons.person_outline_rounded,
                          title: 'A decisão final é humana',
                          description: selectedAlert.humanDecisionNotice,
                        ),
                      ],
                      const SizedBox(height: 29),
                      const _Footer(),
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

class _AlertsHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String eyebrow;
  final String? cityName;
  final String? cityState;
  final bool demonstration;
  final bool loading;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;

  const _AlertsHero({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.cityName,
    required this.cityState,
    required this.demonstration,
    this.loading = false,
    this.onBack,
    this.onRefresh,
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
              child: CustomPaint(painter: _AlertsAtmospherePainter()),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(onBack == null ? 20 : 17, 17, 20, 29),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (onBack != null) ...[
                      IconButton(
                        tooltip: 'Voltar',
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: onBack == null ? 38 : 35,
                      height: onBack == null ? 38 : 35,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (onRefresh != null || loading)
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
                                    color: Colors.white,
                                    strokeWidth: 2,
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
                Row(
                  children: [
                    const Icon(Icons.circle, size: 7, color: AppColors.breeze),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        eyebrow,
                        style: const TextStyle(
                          color: AppColors.breeze,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFD3E8E5),
                    fontSize: 13,
                    height: 1.6,
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
                      Row(
                        children: [
                          Icon(
                            demonstration
                                ? Icons.science_outlined
                                : Icons.location_on_outlined,
                            color: AppColors.breeze,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            demonstration
                                ? 'CENÁRIO DEMONSTRATIVO'
                                : 'CIDADE MONITORADA',
                            style: const TextStyle(
                              color: AppColors.breeze,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        demonstration
                            ? 'Simulação ilustrativa'
                            : cityName ?? 'Carregando localidade...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        demonstration
                            ? 'Dados fictícios de demonstração'
                            : cityState == null
                            ? 'Aguardando seleção'
                            : '$cityState • Brasil',
                        style: const TextStyle(
                          color: Color(0xFFCAE5DF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 19),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: AppColors.breeze,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Análises baseadas em médias móveis, '
                                'horários futuros e referências '
                                'brasileiras de qualidade do ar.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
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
                              'Estimativas de modelo, não avisos '
                              'oficiais da CETESB.',
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

class _AlertsAtmospherePainter extends CustomPainter {
  const _AlertsAtmospherePainter();

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

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? colors.onPrimary : colors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? colors.onPrimary : colors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisTransparencyCard extends StatelessWidget {
  final SafeAlertResult report;

  const _AnalysisTransparencyCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Transparência da análise',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Confiança',
                  value: report.confidenceLevel,
                  subtitle: report.demonstration
                      ? 'Dados fictícios'
                      : 'Sem validação local',
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _SummaryMetric(
                  label: 'Cobertura dos dados',
                  value: '${report.futureCoveragePercentage}%',
                  subtitle:
                      '${report.validFuturePoints} de ${report.horizonHours} horas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            report.confidenceDescription,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            report.futureCoverageDescription,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlertsCard extends StatelessWidget {
  const _EmptyAlertsCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 61,
            height: 61,
            decoration: BoxDecoration(
              color: colors.good.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: colors.good,
              size: 32,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Nenhum alerta identificado',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Não foram identificadas condições de atenção '
            'nos poluentes com dados futuros suficientes. '
            'Isso não garante ausência de riscos ambientais.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final PredictiveAlert alert;
  final bool fromCache;
  final bool demonstration;
  final String? cityName;

  const _AlertCard({
    required this.alert,
    required this.fromCache,
    required this.demonstration,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final color = _priorityColor(alert.priority, colors);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed(
          'alerta-detalhe',
          pathParameters: {'poluente': alert.id},
          queryParameters: {'simulacao': demonstration ? '1' : '0'},
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: color,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.pollutantName,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                alert.title,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(label: alert.priorityName, color: color),
                  _StatusPill(
                    label: alert.classification.nome,
                    color: _classificationColor(
                      alert.classification.nome,
                      colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Confiança: ${alert.confidenceLevel} '
                '• Cobertura: ${alert.coveragePercentage}%',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 16),
              Text(
                'MAIOR MÉDIA MÓVEL PREVISTA',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                children: [
                  Text(
                    _formatNumber(alert.peakAverage),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 33,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'µg/m³',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 17,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pico estimado: ${_formatWallTime(alert.peakTime)}\n'
                      '${_timeContext(cityName, demonstration)}',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (fromCache && !demonstration) ...[
                const SizedBox(height: 13),
                const _InformationCard(
                  icon: Icons.storage_outlined,
                  title: 'Prévia offline',
                  description: 'Esta previsão armazenada requer confirmação.',
                  compact: true,
                ),
              ],
              if (demonstration) ...[
                const SizedBox(height: 13),
                const _InformationCard(
                  icon: Icons.science_outlined,
                  title: 'Demonstração',
                  description: 'Os valores apresentados são ilustrativos.',
                  compact: true,
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalhes',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertSpotlight extends StatelessWidget {
  final PredictiveAlert alert;

  const _AlertSpotlight({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _priorityColor(alert.priority, AppThemePalette.light);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: AppColors.breeze,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'ALERTA PREDITIVO',
                style: TextStyle(
                  color: AppColors.breeze,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            alert.pollutantName,
            style: const TextStyle(
              color: AppColors.mist,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            alert.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 19),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _StatusPill(
                label: alert.priorityName,
                color: color,
                darkBackground: true,
              ),
              _StatusPill(
                label: alert.classification.nome,
                color: _classificationColor(
                  alert.classification.nome,
                  AppThemePalette.light,
                ),
                darkBackground: true,
              ),
            ],
          ),
          const SizedBox(height: 23),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.breeze,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Este alerta é uma estimativa gerada '
                    'a partir de dados previstos. '
                    'Não representa medição local '
                    'ou aviso oficial.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.55,
                    ),
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

class _SocialImpactCard extends StatelessWidget {
  final List<PredictiveAlert> alerts;

  const _SocialImpactCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final earliest = alerts.reduce(
      (current, next) =>
          current.peakTime.isBefore(next.peakTime) ? current : next,
    );

    return _BenefitCard(alert: earliest);
  }
}

class _BenefitCard extends StatelessWidget {
  final PredictiveAlert alert;

  const _BenefitCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: colors.primary,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Indicador de benefício social potencial',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            alert.leadTimeLabel,
            style: TextStyle(
              color: colors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Antecedência estimada até o pico previsto '
            'de ${alert.pollutantName}.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            alert.socialBenefitIndicator,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool darkBackground;

  const _StatusPill({
    required this.label,
    required this.color,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: darkBackground ? color : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: darkBackground ? Colors.white : color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool compact;
  final bool loading;
  final VoidCallback? onRetry;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.description,
    this.compact = false,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              else
                Icon(icon, color: colors.primary, size: compact ? 19 : 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
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
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Center(
      child: Text(
        'Aeris Pulse • Inteligência atmosférica',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.textSecondary, fontSize: 11),
      ),
    );
  }
}

Color _priorityColor(AlertPriority priority, AppThemePalette colors) {
  switch (priority) {
    case AlertPriority.preventiva:
      return colors.moderate;
    case AlertPriority.elevada:
      return colors.poor;
    case AlertPriority.critica:
      return colors.veryPoor;
  }
}

Color _classificationColor(String name, AppThemePalette colors) {
  final label = name.toLowerCase();

  if (label.contains('péssima') || label.contains('pessima')) {
    return colors.severe;
  }

  if (label.contains('muito ruim')) {
    return colors.veryPoor;
  }

  if (label.contains('ruim')) {
    return colors.poor;
  }

  if (label.contains('moderada')) {
    return colors.moderate;
  }

  return colors.good;
}

String _formatNumber(double number) {
  return number.toStringAsFixed(1).replaceAll('.', ',');
}

String _timeContext(String? cityName, bool demonstration) {
  return demonstration
      ? 'Horário ilustrativo da simulação'
      : 'Horário local de ${cityName ?? 'cidade monitorada'}';
}

String _formatWallTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$day/$month às $hour:$minute';
}
