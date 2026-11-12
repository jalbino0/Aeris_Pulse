import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';

class ThemeModeSettingsCard extends ConsumerStatefulWidget {
  const ThemeModeSettingsCard({super.key});

  @override
  ConsumerState<ThemeModeSettingsCard> createState() =>
      _ThemeModeSettingsCardState();
}

class _ThemeModeSettingsCardState extends ConsumerState<ThemeModeSettingsCard> {
  bool _saving = false;

  Future<void> _selectMode(ThemeMode mode) async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref.read(appThemeModeProvider.notifier).setMode(mode);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar o tema.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final preference = ref.watch(appThemeModeProvider);
    final selected = preference.asData?.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
              Icon(Icons.palette_outlined, color: colors.primary, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tema do aplicativo',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_saving || preference.isLoading)
                SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    color: colors.primary,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Escolha a aparência que prefere para o Aeris Pulse.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          if (preference.hasError)
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(appThemeModeProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar carregar a aparência'),
            )
          else
            for (final mode in const [
              ThemeMode.light,
              ThemeMode.dark,
              ThemeMode.system,
            ]) ...[
              _ThemeChoice(
                mode: mode,
                selected: mode == selected,
                enabled: !_saving && !preference.isLoading,
                onTap: () => _selectMode(mode),
              ),
              if (mode != ThemeMode.system) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final ThemeMode mode;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    final title = switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
      ThemeMode.system => 'Automático',
    };

    final subtitle = switch (mode) {
      ThemeMode.light => 'Aparência clara do Aeris Pulse',
      ThemeMode.dark => 'Aparência escura do Aeris Pulse',
      ThemeMode.system => 'Acompanhar o tema do Android',
    };

    final icon = switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };

    return Semantics(
      button: true,
      selected: selected,
      label: 'Tema $title',
      child: Material(
        color: selected ? colors.infoBackground : colors.surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 23),
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
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? colors.primary : colors.border,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
