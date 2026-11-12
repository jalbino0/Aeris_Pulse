import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../data/entry_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busy = false;

  Future<void> _continueAsGuest() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await const EntryPreferences().markCompleted();

      if (!mounted) {
        return;
      }

      context.go('/');
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a preferência de entrada.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 780;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _WelcomeHero(compact: compact)),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _WelcomeActions(
                    busy: _busy,
                    onGuest: _continueAsGuest,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  final bool compact;

  const _WelcomeHero({required this.compact});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF071B20), Color(0xFF12434A)]
              : const [AppColors.primary, AppColors.primary],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              compact ? 16 : 25,
              24,
              compact ? 22 : 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: 34,
                      height: 34,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Aeris Pulse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 21 : 30),
                Text(
                  'Entenda o ar.\nCuide do seu dia.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 29 : 33,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  'Qualidade do ar, previsões e alertas '
                  'para os lugares que fazem parte da sua vida.',
                  style: TextStyle(
                    color: Color(0xFFCCE3E1),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 19 : 25),
                const _AirQualityPreview(),
                const SizedBox(height: 15),
                const Wrap(
                  spacing: 7,
                  runSpacing: 8,
                  children: [
                    _FeatureChip(
                      icon: Icons.air_rounded,
                      label: 'Dados ambientais',
                    ),
                    _FeatureChip(
                      icon: Icons.notifications_none_rounded,
                      label: 'Alertas preditivos',
                    ),
                    _FeatureChip(
                      icon: Icons.location_on_outlined,
                      label: 'Múltiplas cidades',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AirQualityPreview extends StatelessWidget {
  const _AirQualityPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.095),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Color(0xFFC6E8DE),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Exemplo: Pinheiros, São Paulo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFE0F3EF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F6ED),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Boa',
                  style: TextStyle(
                    color: Color(0xFF16684B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '28',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 65,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -3,
                ),
              ),
              SizedBox(width: 12),
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IQAr',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Faixa boa: 0–40',
                      style: TextStyle(color: Color(0xFFC6E5DF), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'PM2.5',
                  value: '14',
                  unit: 'µg/m³',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'PM10',
                  value: '35',
                  unit: 'µg/m³',
                ),
              ),
              Expanded(
                child: _PreviewMetric(label: 'Umidade', value: '68', unit: '%'),
              ),
              Expanded(
                child: _PreviewMetric(
                  label: 'Previsão 15h',
                  value: '56',
                  unit: 'Moderada',
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Prévia demonstrativa • valores ilustrativos',
            style: TextStyle(color: Color(0xFFAACDC7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool highlight;

  const _PreviewMetric({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFC1DEDB), fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          unit,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlight
                ? const Color(0xFFF7BC57)
                : const Color(0xFFB4D5D0),
            fontSize: 9,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFC6E8DE)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFDEEFEB), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  final bool busy;
  final VoidCallback onGuest;

  const _WelcomeActions({required this.busy, required this.onGuest});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: colors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.good.withValues(alpha: 0.12)
                        : const Color(0xFFE6F4ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? colors.good.withValues(alpha: 0.35)
                          : const Color(0xFFBFE4D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: isDark ? colors.good : const Color(0xFF237458),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Crie sua conta para sincronizar '
                          'cidades favoritas e preferências.',
                          style: TextStyle(
                            color: isDark
                                ? colors.text
                                : const Color(0xFF226C54),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 53,
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () => context.pushNamed(
                            'autenticacao',
                            queryParameters: {'modo': 'cadastro'},
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 53,
                  child: OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => context.pushNamed('autenticacao'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Fazer login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.border)),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 49,
                  child: TextButton(
                    onPressed: busy ? null : onGuest,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                    ),
                    child: busy
                        ? SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Entrar sem cadastro',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 9),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore sem criar uma conta. '
                  'Você pode se cadastrar depois.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    height: 1.5,
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
