import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app_shell.dart';
import 'core/domain/qualidade_ar_br.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/air_quality/presentation/air_quality_screen.dart';
import 'features/air_quality/presentation/pollutants_screen.dart';
import 'features/alerts/data/local_alert_notification_service.dart';
import 'features/alerts/presentation/alerts_screen.dart';
import 'features/alerts/presentation/real_alert_notification_observer.dart';
import 'features/auth/presentation/account_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/privacy_screen.dart';
import 'features/forecasts/presentation/forecast_screen.dart';
import 'features/home/home_screen.dart';
import 'features/locations/presentation/locations_screen.dart';
import 'features/locations/providers/selected_city_provider.dart';
import 'features/onboarding/data/entry_preferences.dart';
import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final showWelcome = await const EntryPreferences().shouldShowWelcome();

  String? notificationPayload;

  try {
    notificationPayload = await LocalAlertNotificationService.instance
        .getLaunchNotificationPayload();
  } catch (error) {
    debugPrint('Falha ao recuperar notificação inicial: $error');
  }

  runApp(
    ProviderScope(
      child: AerisPulseApp(
        showWelcome: showWelcome,
        initialNotificationPayload: notificationPayload,
      ),
    ),
  );
}

class AerisPulseApp extends ConsumerStatefulWidget {
  final bool showWelcome;
  final String? initialNotificationPayload;

  const AerisPulseApp({
    super.key,
    required this.showWelcome,
    this.initialNotificationPayload,
  });

  @override
  ConsumerState<AerisPulseApp> createState() => _AerisPulseAppState();
}

class _AerisPulseAppState extends ConsumerState<AerisPulseApp> {
  late final GoRouter _router;

  Future<void> _handleNotificationTap(String payload) async {
    if (!mounted) {
      return;
    }

    if (payload == 'alertas') {
      _router.goNamed('alertas');
      return;
    }

    final parts = payload.split(':');

    if (parts.length != 3 || parts.first != 'alerta') {
      _router.goNamed('alertas');
      return;
    }

    final pollutantId = parts[1];
    final notificationCityId = int.tryParse(parts[2]);

    final validPollutant = PoluenteBr.values.any(
      (pollutant) => pollutant.name == pollutantId,
    );

    if (!validPollutant || notificationCityId == null) {
      _router.goNamed('alertas');
      return;
    }

    try {
      final container = ProviderScope.containerOf(context, listen: false);

      final selectedCity = await container.read(selectedCityProvider.future);

      if (!mounted) {
        return;
      }

      if (selectedCity.id != notificationCityId) {
        _router.goNamed('alertas');
        return;
      }

      _router.goNamed(
        'alerta-detalhe',
        pathParameters: {'poluente': pollutantId},
      );
    } catch (error) {
      debugPrint('Falha ao abrir detalhes da notificação: $error');

      if (mounted) {
        _router.goNamed('alertas');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: widget.showWelcome ? '/boas-vindas' : '/',
      routes: [
        GoRoute(
          path: '/boas-vindas',
          name: 'boas-vindas',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/autenticacao',
          name: 'autenticacao',
          builder: (context, state) => AuthScreen(
            startRegister: state.uri.queryParameters['modo'] == 'cadastro',
          ),
        ),
        GoRoute(
          path: '/privacidade',
          name: 'privacidade',
          builder: (context, state) => const PrivacyScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return RealAlertNotificationObserver(
              child: AppShell(
                navigationShell: navigationShell,
                currentPath: state.uri.path,
                showForecastShortcut: state.uri.path == '/ar',
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'inicio',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/ar',
                  name: 'qualidade-ar',
                  builder: (context, state) => const AirQualityScreen(),
                  routes: [
                    GoRoute(
                      path: 'poluentes',
                      name: 'poluentes',
                      builder: (context, state) => const PollutantsScreen(),
                    ),
                    GoRoute(
                      path: 'previsoes',
                      name: 'previsoes',
                      builder: (context, state) => const ForecastScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/locais',
                  name: 'localidades',
                  builder: (context, state) => const LocationsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/alertas',
                  name: 'alertas',
                  builder: (context, state) =>
                      const PredictiveAlertsGate(child: AlertsScreen()),
                  routes: [
                    GoRoute(
                      path: 'detalhe/:poluente',
                      name: 'alerta-detalhe',
                      builder: (context, state) {
                        return PredictiveAlertsGate(
                          child: AlertDetailsScreen(
                            pollutantId: state.pathParameters['poluente'] ?? '',
                            demonstration:
                                state.uri.queryParameters['simulacao'] == '1',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/conta',
                  name: 'conta',
                  builder: (context, state) => const AccountScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/configuracoes',
                  name: 'configuracoes',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    LocalAlertNotificationService.instance.setOnNotificationTap(
      _handleNotificationTap,
    );

    final initialPayload = widget.initialNotificationPayload;

    if (initialPayload != null && !widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleNotificationTap(initialPayload);
        }
      });
    }
  }

  @override
  void dispose() {
    LocalAlertNotificationService.instance.setOnNotificationTap(null);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(appThemeModeProvider).asData?.value ?? ThemeMode.light;

    return MaterialApp.router(
      title: 'Aeris Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
