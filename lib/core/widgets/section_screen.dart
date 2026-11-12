import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class SectionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;

  const SectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final typography = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Aeris Pulse',
                  style: typography.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  title,
                  style: typography.headlineMedium?.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: typography.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B3439) : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark
                        ? Border.all(color: const Color(0xFF24545A))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: AppColors.breeze, size: 36),
                      const SizedBox(height: 24),
                      const Text(
                        'Inteligência ambiental',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Esta seção está sendo preparada para apresentar informações ambientais reais.',
                        style: TextStyle(
                          color: AppColors.mist,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Funcionalidades planejadas',
                  style: typography.titleLarge?.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                for (final feature in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              feature,
                              style: typography.bodyMedium?.copyWith(
                                color: colors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.infoBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aguardando integração com as fontes de dados ambientais.',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 12,
                            height: 1.5,
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
