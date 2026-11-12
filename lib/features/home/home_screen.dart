import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers/global_refresh_provider.dart';
import '../../core/theme/app_theme.dart';
import '../air_quality/providers/air_quality_provider.dart';
import '../locations/providers/selected_city_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refreshAll(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref
          .read(globalRefreshProvider.notifier)
          .refreshAll();

      if (!context.mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar os dados ambientais.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.paletteOf(context);
    final selectedCityState = ref.watch(selectedCityProvider);
    final selectedCity = selectedCityState.asData?.value;
    final airQuality = ref.watch(airQualityProvider);
    final reading = airQuality.asData?.value;
    final refreshing = ref.watch(globalRefreshProvider);

    final validReading =
        reading != null &&
            selectedCity != null &&
            reading.location == '${selectedCity.name} (${selectedCity.state})'
        ? reading
        : null;

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
                _HomeHero(
                  cityName: selectedCity?.name,
                  cityState: selectedCity?.state,
                  referenceTime: validReading?.formattedTime,
                  loading: airQuality.isLoading && validReading == null,
                  hasError: airQuality.hasError && validReading == null,
                  refreshing: refreshing,
                  onRefresh: refreshing
                      ? null
                      : () => _refreshAll(context, ref),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'DADOS AMBIENTAIS',
                        title: 'O que estamos observando',
                        description:
                            'Concentrações estimadas para '
                            'o horário de referência.',
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 500 ? 3 : 2;

                          const spacing = 12.0;

                          final itemWidth =
                              (constraints.maxWidth - spacing * (columns - 1)) /
                              columns;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              _MetricCard(
                                width: itemWidth,
                                label: 'MP2,5',
                                name: 'Partículas finas',
                                value: validReading?.pm25,
                                icon: Icons.grain,
                              ),
                              _MetricCard(
                                width: itemWidth,
                                label: 'MP10',
                                name: 'Partículas',
                                value: validReading?.pm10,
                                icon: Icons.blur_on,
                              ),
                              _MetricCard(
                                width: itemWidth,
                                label: 'Ozônio',
                                name: 'O₃',
                                value: validReading?.ozone,
                                icon: Icons.bubble_chart_outlined,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const _InformationBanner(
                        icon: Icons.info_outline_rounded,
                        title: 'Entenda os indicadores',
                        description:
                            'Os números representam concentrações '
                            'estimadas em µg/m³, não o índice '
                            'numérico IQAr. A classificação da '
                            'qualidade do ar considera médias '
                            'e períodos específicos para cada poluente.',
                      ),
                      const SizedBox(height: 34),
                      const _SectionHeading(
                        eyebrow: 'EXPLORE MAIS',
                        title: 'Inteligência ambiental',
                        description:
                            'Explore previsões e análises '
                            'para entender melhor o ar da sua cidade.',
                      ),
                      const SizedBox(height: 18),
                      _ExploreCard(
                        icon: Icons.show_chart_rounded,
                        title: 'Previsões e tendências',
                        description:
                            'Acompanhe a evolução prevista '
                            'dos poluentes ao longo do tempo.',
                        onTap: () => context.goNamed('previsoes'),
                      ),
                      const SizedBox(height: 12),
                      _ExploreCard(
                        icon: Icons.notifications_active_outlined,
                        title: 'Alertas preditivos',
                        description:
                            'Consulte situações de atenção '
                            'e as limitações das projeções.',
                        onTap: () => context.goNamed('alertas'),
                      ),
                      const SizedBox(height: 12),
                      _ExploreCard(
                        icon: Icons.location_on_outlined,
                        title: 'Suas cidades',
                        description:
                            'Alterne o monitoramento '
                            'e gerencie seus favoritos.',
                        onTap: () => context.goNamed('localidades'),
                      ),
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
}

class _HomeHero extends StatelessWidget {
  final String? cityName;
  final String? cityState;
  final String? referenceTime;
  final bool loading;
  final bool hasError;
  final bool refreshing;
  final VoidCallback? onRefresh;

  const _HomeHero({
    required this.cityName,
    required this.cityState,
    required this.referenceTime,
    required this.loading,
    required this.hasError,
    required this.refreshing,
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
              child: CustomPaint(painter: _HomeAtmospherePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      height: 38,
                      width: 38,
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
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    _HeroIconButton(
                      tooltip: 'Atualizar dados ambientais',
                      icon: Icons.refresh_rounded,
                      loading: refreshing,
                      onPressed: onRefresh,
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.breeze),
                    SizedBox(width: 9),
                    Text(
                      'MONITORAMENTO AMBIENTAL',
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
                  'Seu ar, agora',
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
                  'Inteligência no ar. Clareza na vida.',
                  style: TextStyle(
                    color: Color(0xFFD3E8E5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 25),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (loading)
                              const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.breeze,
                                ),
                              )
                            else
                              Icon(
                                hasError
                                    ? Icons.wifi_off_outlined
                                    : Icons.schedule_outlined,
                                color: AppColors.breeze,
                                size: 18,
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                loading
                                    ? 'Consultando dados ambientais...'
                                    : referenceTime != null
                                    ? 'Referência: $referenceTime\n'
                                          'Horário local de ${cityName ?? 'cidade monitorada'}'
                                    : hasError
                                    ? 'Dados indisponíveis. '
                                          'Verifique a conexão e '
                                          'tente atualizar.'
                                    : 'Preparando as informações '
                                          'da cidade selecionada.',
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
                              'Fonte: Open-Meteo / CAMS. '
                              'Estimativas de modelos atmosféricos, '
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

class _HeroIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  const _HeroIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _HomeAtmospherePainter extends CustomPainter {
  const _HomeAtmospherePainter();

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

class _MetricCard extends StatelessWidget {
  final double width;
  final String label;
  final String name;
  final double? value;
  final IconData icon;

  const _MetricCard({
    required this.width,
    required this.label,
    required this.name,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    final formatted = value == null
        ? '—'
        : value!.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 169),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: colors.primary, size: 19),
          ),
          const SizedBox(height: 13),
          Text(
            label,
            style: TextStyle(
              color: colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            style: TextStyle(color: colors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 5,
            runSpacing: 4,
            children: [
              Text(
                formatted,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.9,
                  height: 1.1,
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'µg/m³',
                    style: TextStyle(color: colors.textSecondary, fontSize: 10),
                  ),
                ),
            ],
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
      padding: const EdgeInsets.all(16),
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
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExploreCard({
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
