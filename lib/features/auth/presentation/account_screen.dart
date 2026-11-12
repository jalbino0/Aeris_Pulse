import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../data/account_deletion_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) {
        return;
      }

      context.go('/boas-vindas');
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível sair da conta.')),
      );
    }
  }

  Future<void> _confirmAccountDeletion(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _DeleteAccountDialog(),
    );

    if (deleted == true && context.mounted) {
      context.go('/boas-vindas');
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final colors = AppTheme.paletteOf(context);
        final user = snapshot.data;
        final isLoggedIn = user != null;

        final registeredName = user?.displayName?.trim();

        final displayName = isLoggedIn
            ? registeredName != null && registeredName.isNotEmpty
                  ? registeredName
                  : 'Minha conta'
            : 'Modo visitante';

        final email = isLoggedIn
            ? user.email ?? 'Conta autenticada'
            : 'Explore sem precisar de cadastro';

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
                    _AccountHero(
                      displayName: displayName,
                      email: email,
                      isLoggedIn: isLoggedIn,
                      onBack: () => _goBack(context),
                      onSettings: () => context.pushNamed('configuracoes'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeading(
                            eyebrow: 'SUA EXPERIÊNCIA',
                            title: isLoggedIn
                                ? 'Conta e preferências'
                                : 'Explore do seu jeito',
                            description: isLoggedIn
                                ? 'Veja como suas informações '
                                      'e preferências são armazenadas.'
                                : 'Você pode utilizar os recursos '
                                      'do Aeris Pulse mesmo sem cadastro.',
                          ),
                          const SizedBox(height: 21),
                          if (!isLoggedIn) ...[
                            const _InfoSection(
                              icon: Icons.phone_android_outlined,
                              title: 'Preferências locais',
                              description:
                                  'Sua cidade monitorada e seus '
                                  'favoritos são armazenados '
                                  'neste dispositivo.',
                            ),
                            const SizedBox(height: 12),
                            const _InfoSection(
                              icon: Icons.cloud_outlined,
                              title: 'Sincronização opcional',
                              description:
                                  'Crie uma conta para armazenar '
                                  'suas cidades favoritas e '
                                  'preferências no Firebase. '
                                  'Os dados de visitante '
                                  'permanecem separados.',
                            ),
                            const SizedBox(height: 29),
                            const _SectionHeading(
                              eyebrow: 'COMECE POR AQUI',
                              title: 'Conecte sua experiência',
                              description:
                                  'Acesse sua conta ou crie uma '
                                  'para salvar suas preferências '
                                  'na nuvem.',
                            ),
                            const SizedBox(height: 19),
                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: () {
                                  context.pushNamed(
                                    'autenticacao',
                                    queryParameters: {'modo': 'cadastro'},
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_1_outlined,
                                      size: 19,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Criar conta',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 53,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.pushNamed('autenticacao');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  backgroundColor: colors.surface,
                                  side: BorderSide(color: colors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.login_rounded, size: 19),
                                label: const Text(
                                  'Já tenho uma conta',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const _InfoSection(
                              icon: Icons.cloud_done_outlined,
                              title: 'Preferências na nuvem',
                              description:
                                  'Seus favoritos e sua cidade '
                                  'monitorada são armazenados '
                                  'no Cloud Firestore.',
                            ),
                            const SizedBox(height: 12),
                            const _InfoSection(
                              icon: Icons.storage_outlined,
                              title: 'Cache ambiental',
                              description:
                                  'Os dados ambientais também '
                                  'são armazenados localmente '
                                  'para permitir consultas offline.',
                            ),
                            const SizedBox(height: 12),
                            const _InfoSection(
                              icon: Icons.shield_outlined,
                              title: 'Privacidade da conta',
                              description:
                                  'O acesso às suas preferências '
                                  'na nuvem é protegido pelas '
                                  'regras de segurança do Firebase.',
                            ),
                            const SizedBox(height: 12),
                            const _InfoSection(
                              icon: Icons.person_outline_rounded,
                              title: 'Dados de visitante',
                              description:
                                  'Os dados armazenados localmente '
                                  'no modo visitante não são '
                                  'importados automaticamente '
                                  'para sua conta.',
                            ),
                          ],
                          const SizedBox(height: 31),
                          const _SectionHeading(
                            eyebrow: 'GERENCIAMENTO',
                            title: 'Acesso e controle',
                            description:
                                'Gerencie sua experiência '
                                'e as opções do aplicativo.',
                          ),
                          const SizedBox(height: 18),
                          _ActionCard(
                            icon: Icons.settings_outlined,
                            title: 'Configurações',
                            description:
                                'Personalize alertas e '
                                'preferências do aplicativo.',
                            onTap: () => context.pushNamed('configuracoes'),
                          ),
                          const SizedBox(height: 13),
                          _ActionCard(
                            icon: Icons.shield_outlined,
                            title: 'Privacidade e dados',
                            description:
                                'Entenda como suas informações '
                                'são armazenadas e gerenciadas.',
                            onTap: () => context.pushNamed('privacidade'),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(height: 13),
                            _ActionCard(
                              icon: Icons.logout_rounded,
                              title: 'Sair da conta',
                              description:
                                  'Encerre sua sessão e volte '
                                  'para a tela de boas-vindas.',
                              destructive: true,
                              onTap: () => _signOut(context),
                            ),
                            const SizedBox(height: 13),
                            _ActionCard(
                              icon: Icons.delete_forever_outlined,
                              title: 'Excluir minha conta',
                              description:
                                  'Remova sua conta e suas preferências '
                                  'salvas na nuvem de forma permanente.',
                              destructive: true,
                              onTap: () => _confirmAccountDeletion(context),
                            ),
                          ],
                          const SizedBox(height: 22),
                          const _InformationBanner(
                            icon: Icons.info_outline_rounded,
                            title: 'Sua experiência, suas escolhas',
                            description:
                                'O Aeris Pulse permite acompanhar '
                                'as condições ambientais sem '
                                'cadastro obrigatório. Uma conta '
                                'oferece a opção de manter '
                                'preferências vinculadas ao usuário.',
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
      },
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _busy = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_busy) {
      return;
    }

    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _error = 'Informe sua senha para confirmar a exclusão.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await AccountDeletionService().deleteAccount(password: password);

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
      });

      Navigator.of(context).pop(true);
    } on AccountDeletionException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Não foi possível concluir a exclusão. '
            'Verifique sua conexão e tente novamente.';
      });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Excluir minha conta',
          style: TextStyle(
            color: colors.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação é permanente e removerá sua conta do '
                'Firebase Authentication, suas cidades favoritas '
                'e sua cidade monitorada armazenadas no Firestore.',
                style: TextStyle(color: colors.text, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                'As preferências locais do modo visitante e o cache '
                'ambiental deste dispositivo não serão apagados. '
                'É necessária uma conexão com a internet.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 19),
              TextField(
                controller: _passwordController,
                autofocus: false,
                enabled: !_busy,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _deleteAccount(),
                decoration: InputDecoration(
                  labelText: 'Senha atual',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: colors.primary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colors.textSecondary,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 13),
                Text(
                  _error!,
                  style: TextStyle(
                    color: colors.veryPoor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _busy ? null : _deleteAccount,
            style: FilledButton.styleFrom(
              backgroundColor: colors.veryPoor,
              foregroundColor: isDark ? const Color(0xFF32151B) : Colors.white,
            ),
            child: _busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? const Color(0xFF32151B) : Colors.white,
                    ),
                  )
                : const Text('Excluir conta'),
          ),
        ],
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  final String displayName;
  final String email;
  final bool isLoggedIn;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _AccountHero({
    required this.displayName,
    required this.email,
    required this.isLoggedIn,
    required this.onBack,
    required this.onSettings,
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
              child: CustomPaint(painter: _AccountAtmospherePainter()),
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
                      child: IconButton(
                        tooltip: 'Configurações',
                        onPressed: onSettings,
                        icon: const Icon(
                          Icons.settings_outlined,
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
                      'SEU ESPAÇO AERIS',
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
                  'Seu perfil,\nsuas escolhas.',
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
                  'Uma experiência feita para você '
                  'acompanhar o ar do seu jeito.',
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
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.19),
                              ),
                            ),
                            child: Icon(
                              isLoggedIn
                                  ? Icons.verified_user_outlined
                                  : Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  email,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFCAE5DF),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLoggedIn
                                  ? Icons.cloud_done_outlined
                                  : Icons.phone_android_outlined,
                              color: AppColors.breeze,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isLoggedIn
                                    ? 'Conta conectada • Preferências na nuvem'
                                    : 'Acesso visitante • Preferências locais',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.breeze,
                              size: 17,
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

class _AccountAtmospherePainter extends CustomPainter {
  const _AccountAtmospherePainter();

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

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoSection({
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
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final accent = destructive ? colors.veryPoor : colors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
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
                  color: destructive
                      ? isDark
                            ? colors.veryPoor.withValues(alpha: 0.12)
                            : const Color(0xFFFFF1F0)
                      : colors.infoBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: accent, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: destructive ? accent : colors.text,
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
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
            ],
          ),
        ),
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
