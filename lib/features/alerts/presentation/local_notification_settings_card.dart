import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../data/local_alert_notification_service.dart';

class LocalNotificationSettingsCard extends StatefulWidget {
  const LocalNotificationSettingsCard({super.key});

  @override
  State<LocalNotificationSettingsCard> createState() =>
      _LocalNotificationSettingsCardState();
}

class _LocalNotificationSettingsCardState
    extends State<LocalNotificationSettingsCard> {
  bool _enabled = false;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final enabled = await LocalAlertNotificationService.instance.isEnabled();

      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = false;
        _loading = false;
      });

      _message('Não foi possível verificar as notificações.');
    }
  }

  void _message(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _changeEnabled(bool enabled) async {
    if (_busy || _loading) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final result = await LocalAlertNotificationService.instance.setEnabled(
        enabled,
      );

      if (!mounted) {
        return;
      }

      final effectiveEnabled = await LocalAlertNotificationService.instance
          .isEnabled();

      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = effectiveEnabled;
      });

      if (enabled && result && effectiveEnabled) {
        _message('Notificações ambientais ativadas.');
      } else if (enabled) {
        _message(
          'As notificações não foram autorizadas. '
          'Verifique as permissões do Android.',
        );
      } else {
        _message('Notificações ambientais desativadas.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _message('Não foi possível alterar as notificações.');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _sendTest() async {
    if (!_enabled || _busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await LocalAlertNotificationService.instance.showTestNotification();

      if (!mounted) {
        return;
      }

      _message(
        'Notificação de teste enviada. '
        'Verifique a central de notificações do Android.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _message(
        'Não foi possível enviar a notificação. '
        'Confira as permissões do aplicativo.',
      );

      await _load();
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
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
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
                      'Notificações ambientais',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Receba avisos sobre condições '
                      'elevadas ou críticas identificadas '
                      'nas previsões.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              if (_loading)
                SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              else
                Switch(
                  value: _enabled,
                  activeThumbColor: colors.primary,
                  onChanged: _busy ? null : _changeEnabled,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.infoBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: colors.info, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Os avisos dependem de previsões atualizadas. '
                    'A ativação não representa monitoramento '
                    'contínuo com o aplicativo fechado. '
                    'Alertas demonstrativos não geram '
                    'notificações ambientais reais.',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _enabled && !_busy ? _sendTest : null,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Enviar notificação de teste'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
