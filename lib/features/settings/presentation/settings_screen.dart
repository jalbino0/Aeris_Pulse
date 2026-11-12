import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../alerts/presentation/local_notification_settings_card.dart';
import 'theme_mode_settings_card.dart';
import '../../auth/providers/auth_user_provider.dart';
import '../../locations/providers/selected_city_provider.dart';
import '../providers/alert_preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.paletteOf(context);
    final alerts = ref.watch(predictiveAlertsEnabledProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final auth = ref.watch(authUserIdProvider);

    final city = selectedCity.asData?.value;
    final cityName =
        city?.name ??
        (selectedCity.isLoading
            ? 'Carregando cidade...'
            : 'Cidade indisponível');
    final cityState = city?.state;
    final isLoggedIn = auth.asData?.value != null;

    final accountStatus = auth.isLoading
        ? 'Verificando sua conta...'
        : isLoggedIn
        ? 'Conta conectada'
        : 'Modo visitante';

    final alertsEnabled = alerts.asData?.value ?? true;

    Future<void> changeAlerts(bool enabled) async {
      try {
        await ref
            .read(predictiveAlertsEnabledProvider.notifier)
            .setEnabled(enabled);
      } catch (_) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar a preferência de alertas.'),
          ),
        );
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
                _SettingsHero(
                  cityName: cityName,
                  cityState: cityState,
                  accountStatus: accountStatus,
                  onBack: () => _goBack(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'PERSONALIZAÇÃO',
                        title: 'Seu monitoramento',
                        description:
                            'Defina como o Aeris Pulse acompanha '
                            'suas cidades e apresenta as informações.',
                      ),
                      const SizedBox(height: 19),
                      _SettingsActionCard(
                        icon: Icons.location_on_outlined,
                        title: 'Cidade monitorada',
                        description: city == null
                            ? cityName
                            : '${city.name} • ${city.state}',
                        onTap: () => context.goNamed('localidades'),
                      ),
                      const SizedBox(height: 32),
                      const _SectionHeading(
                        eyebrow: 'APARÊNCIA',
                        title: 'Tema do aplicativo',
                        description:
                            'Personalize as cores do Aeris Pulse '
                            'e escolha como ele acompanha o Android.',
                      ),
                      const SizedBox(height: 19),
                      const ThemeModeSettingsCard(),
                      const SizedBox(height: 32),
                      const _SectionHeading(
                        eyebrow: 'ANÁLISES AMBIENTAIS',
                        title: 'Alertas preditivos',
                        description:
                            'Controle a exibição de análises '
                            'baseadas em projeções atmosféricas.',
                      ),
                      const SizedBox(height: 19),
                      _AlertsToggleCard(
                        enabled: alertsEnabled,
                        loading: alerts.isLoading,
                        onChanged: alerts.isLoading || alerts.hasError
                            ? null
                            : changeAlerts,
                      ),
                      if (alerts.hasError) ...[
                        const SizedBox(height: 12),
                        _SettingsActionCard(
                          icon: Icons.refresh_rounded,
                          title: 'Recarregar preferência',
                          description:
                              'Não foi possível recuperar '
                              'a configuração salva.',
                          onTap: () =>
                              ref.invalidate(predictiveAlertsEnabledProvider),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _SettingsActionCard(
                        icon: Icons.science_outlined,
                        title: 'Modo de demonstração',
                        description:
                            'Explore alertas com dados ilustrativos '
                            'na área de análises preditivas.',
                        enabled: alerts.asData?.value == true,
                        onTap: () => context.goNamed('alertas'),
                      ),
                      const SizedBox(height: 14),
                      const _InformationBanner(
                        icon: Icons.info_outline_rounded,
                        title: 'Sobre esta configuração',
                        description:
                            'Esta opção controla a visualização '
                            'dos alertas preditivos no aplicativo. '
                            'As notificações do Android são configuradas '
                            'separadamente e não modificam '
                            'as previsões ambientais.',
                      ),
                      const SizedBox(height: 32),
                      const _SectionHeading(
                        eyebrow: 'AVISOS DO ANDROID',
                        title: 'Notificações ambientais',
                        description:
                            'Escolha se deseja receber avisos locais '
                            'sobre condições elevadas ou críticas. '
                            'As análises preditivas devem estar ativas.',
                      ),
                      const SizedBox(height: 19),
                      const LocalNotificationSettingsCard(),
                      const SizedBox(height: 32),
                      const _SectionHeading(
                        eyebrow: 'SUA EXPERIÊNCIA',
                        title: 'Conta e dados',
                        description:
                            'Consulte suas informações de acesso '
                            'e como seus dados são armazenados.',
                      ),
                      const SizedBox(height: 19),
                      _SettingsActionCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Minha conta',
                        description: accountStatus,
                        onTap: () => context.goNamed('conta'),
                      ),
                      const SizedBox(height: 12),
                      _SettingsActionCard(
                        icon: Icons.shield_outlined,
                        title: 'Privacidade e dados',
                        description:
                            'Entenda o armazenamento, a proteção '
                            'e o gerenciamento das suas informações.',
                        onTap: () => context.pushNamed('privacidade'),
                      ),
                      const SizedBox(height: 12),
                      _SettingsInfoCard(
                        icon: Icons.storage_outlined,
                        title: 'Armazenamento dos dados',
                        description: isLoggedIn
                            ? 'Seus favoritos e a cidade monitorada '
                                  'são vinculados à conta no Firestore. '
                                  'O cache ambiental utiliza SQLite.'
                            : 'As preferências de visitante '
                                  'e o cache ambiental são mantidos '
                                  'localmente no dispositivo.',
                      ),
                      const SizedBox(height: 12),
                      const _SettingsInfoCard(
                        icon: Icons.lock_outline_rounded,
                        title: 'Segurança das preferências',
                        description:
                            'O acesso às preferências na nuvem '
                            'é protegido pelas regras do Firebase. '
                            'Os dados locais permanecem '
                            'armazenados no dispositivo.',
                      ),
                      const SizedBox(height: 23),
                      const _InformationBanner(
                        icon: Icons.cloud_outlined,
                        title: 'Transparência ambiental',
                        description:
                            'O Aeris Pulse utiliza estimativas '
                            'atmosféricas do Open-Meteo/CAMS. '
                            'Esses resultados não representam '
                            'medições oficiais da CETESB.',
                      ),
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

class PredictiveAlertsGate extends ConsumerWidget {
  final Widget child;

  const PredictiveAlertsGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(predictiveAlertsEnabledProvider);

    return preference.when(
      loading: () => const _AlertsGateScreen(
        icon: Icons.hourglass_top_outlined,
        title: 'Preparando seus alertas',
        description:
            'Estamos verificando suas preferências '
            'de análises preditivas.',
        loading: true,
      ),
      error: (error, stackTrace) => _AlertsGateScreen(
        icon: Icons.error_outline_rounded,
        title: 'Preferências indisponíveis',
        description:
            'Não foi possível recuperar a configuração '
            'dos alertas preditivos.',
        actionLabel: 'Tentar novamente',
        actionIcon: Icons.refresh_rounded,
        onAction: () => ref.invalidate(predictiveAlertsEnabledProvider),
      ),
      data: (enabled) {
        if (enabled) {
          return child;
        }

        return _AlertsGateScreen(
          icon: Icons.notifications_off_outlined,
          title: 'Alertas desativados',
          description:
              'Você optou por não exibir análises '
              'preditivas neste dispositivo. '
              'As consultas ambientais e previsões '
              'continuam disponíveis.',
          actionLabel: 'Abrir configurações',
          actionIcon: Icons.settings_outlined,
          onAction: () => context.pushNamed('configuracoes'),
        );
      },
    );
  }
}

class _SettingsHero extends StatelessWidget {
  final String cityName;
  final String? cityState;
  final String accountStatus;
  final VoidCallback onBack;

  const _SettingsHero({
    required this.cityName,
    required this.cityState,
    required this.accountStatus,
    required this.onBack,
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
              : const [Color(0xFF073B40), AppColors.primary, Color(0xFF0F6466)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SettingsAtmospherePainter()),
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
                      tooltip: 'Voltar',
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
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22,
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
                      'PERSONALIZE SUA EXPERIÊNCIA',
                      style: TextStyle(
                        color: AppColors.breeze,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Text(
                  'Tudo do\nseu jeito.',
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
                  'Ajuste suas preferências e acompanhe '
                  'o ar com mais controle e clareza.',
                  style: TextStyle(
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
                      const Row(
                        children: [
                          Icon(
                            Icons.tune_outlined,
                            color: AppColors.breeze,
                            size: 18,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'SUAS PREFERÊNCIAS',
                            style: TextStyle(
                              color: AppColors.breeze,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Cidade monitorada',
                        style: TextStyle(
                          color: Color(0xFFCAE5DF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cityName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      if (cityState != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$cityState • Brasil',
                          style: const TextStyle(
                            color: Color(0xFFCAE5DF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 17),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.breeze,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                accountStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.shield_outlined,
                              color: AppColors.breeze,
                              size: 18,
                            ),
                          ],
                        ),
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

class _SettingsAtmospherePainter extends CustomPainter {
  const _SettingsAtmospherePainter();

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

class _SettingsActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool enabled;

  const _SettingsActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: enabled ? colors.primary : colors.textSecondary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? colors.text : colors.textSecondary,
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
                size: 16,
                color: enabled ? colors.primary : colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsToggleCard extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final ValueChanged<bool>? onChanged;

  const _AlertsToggleCard({
    required this.enabled,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: enabled ? colors.primary : colors.border,
          width: enabled ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: colors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análises preditivas',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loading
                      ? 'Carregando sua preferência...'
                      : enabled
                      ? 'Exibição de alertas habilitada.'
                      : 'Exibição de alertas desativada.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          if (loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  color: colors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Switch.adaptive(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SettingsInfoCard({
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: colors.primary, size: 23),
          ),
          const SizedBox(width: 13),
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

class _AlertsGateScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool loading;

  const _AlertsGateScreen({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 17, 20, 25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              Color(0xFF071B20),
                              Color(0xFF0B3439),
                              Color(0xFF12434A),
                            ]
                          : const [
                              Color(0xFF073B40),
                              AppColors.primary,
                              Color(0xFF0F6466),
                            ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/aeris_logo.png',
                        width: 38,
                        height: 38,
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text(
                          'Aeris Pulse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.breeze,
                        size: 23,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                      child: Column(
                        children: [
                          Container(
                            width: 83,
                            height: 83,
                            decoration: BoxDecoration(
                              color: colors.infoBackground,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: loading
                                ? Padding(
                                    padding: const EdgeInsets.all(27),
                                    child: CircularProgressIndicator(
                                      color: colors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Icon(icon, color: colors.primary, size: 42),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          if (onAction != null && actionLabel != null) ...[
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 53,
                              child: FilledButton.icon(
                                onPressed: onAction,
                                icon: Icon(
                                  actionIcon ?? Icons.arrow_forward_rounded,
                                  size: 19,
                                ),
                                label: Text(
                                  actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
