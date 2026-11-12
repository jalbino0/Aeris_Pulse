import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/network/environment_cache_keys.dart';
import '../core/providers/cache_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/locations/providers/selected_city_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final bool showForecastShortcut;
  final String currentPath;

  const AppShell({
    super.key,
    required this.navigationShell,
    this.showForecastShortcut = false,
    required this.currentPath,
  });

  void _selecionarAba(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String? _resource() {
    if (currentPath == '/') {
      return 'home';
    }

    if (currentPath == '/ar' || currentPath == '/ar/poluentes') {
      return 'history';
    }

    if (currentPath == '/ar/previsoes' ||
        currentPath == '/alertas' ||
        currentPath.startsWith('/alertas/detalhe/')) {
      return 'forecast';
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statuses = ref.watch(cacheStatusProvider);
    final city = ref.watch(selectedCityProvider).asData?.value;
    final resource = _resource();

    final status = city != null && resource != null
        ? statuses[EnvironmentCacheKeys.status(city, resource)]
        : null;

    final showNotice =
        status != null && (status.fromCache || !status.cacheSaved);

    final showLocation =
        city != null &&
        currentPath != '/' &&
        currentPath != '/locais' &&
        currentPath != '/conta' &&
        currentPath != '/configuracoes';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (showLocation)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Monitorando ${city.name} • ${city.state}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showNotice)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.infoBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        status.fromCache
                            ? Icons.storage_outlined
                            : Icons.cloud_off_outlined,
                        color: colors.info,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          status.fromCache
                              ? _cachedMessage(resource!, status.savedAt)
                              : 'Os dados foram recebidos da API, '
                                    'mas não foi possível atualizar '
                                    'a cópia offline.',
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
              ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      floatingActionButton: showForecastShortcut
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: () => context.pushNamed('previsoes'),
              icon: const Icon(Icons.show_chart),
              label: const Text('Previsões'),
            )
          : null,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            final selected = states.contains(WidgetState.selected);

            return IconThemeData(
              color: selected
                  ? isDark
                        ? colors.onPrimary
                        : colors.primary
                  : colors.textSecondary,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final selected = states.contains(WidgetState.selected);

            return TextStyle(
              color: selected ? colors.text : colors.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _selecionarAba,
          backgroundColor: colors.surface,
          indicatorColor: isDark ? colors.primary : colors.breeze,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.air_outlined),
              selectedIcon: Icon(Icons.air),
              label: 'Ar',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Locais',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alertas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}

String _cachedMessage(String resource, DateTime savedAt) {
  final formatted = _formatDate(savedAt);

  if (resource == 'forecast') {
    return 'Previsão recuperada do SQLite para a cidade '
        'selecionada. Cópia salva em $formatted. '
        'Os períodos previstos podem estar expirados. '
        'Revalide os alertas com dados recentes.';
  }

  if (resource == 'history') {
    return 'Histórico recuperado do SQLite para a cidade '
        'selecionada. Cópia salva em $formatted. '
        'O gráfico não representa uma atualização em tempo real.';
  }

  return 'Dados recuperados do SQLite para a cidade '
      'selecionada. Última cópia salva em $formatted. '
      'As informações podem estar desatualizadas.';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month às $hour:$minute';
}
