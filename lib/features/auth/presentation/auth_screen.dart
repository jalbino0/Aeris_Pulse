import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../onboarding/data/entry_preferences.dart';

class AuthScreen extends StatefulWidget {
  final bool startRegister;

  const AuthScreen({super.key, this.startRegister = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _register;
  bool _obscurePassword = true;
  bool _busy = false;
  bool _privacyAccepted = false;
  bool _privacyError = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _register = widget.startRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode() {
    if (_busy) {
      return;
    }

    setState(() {
      _register = !_register;
      _error = null;
      _obscurePassword = true;
      _privacyAccepted = false;
      _privacyError = false;
      _passwordController.clear();
    });
  }

  void _goBack() {
    if (_busy) {
      return;
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/boas-vindas');
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!valid) {
      return 'Informe um e-mail válido.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'A senha precisa ter pelo menos 6 caracteres.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (_busy || _formKey.currentState?.validate() != true) {
      return;
    }

    if (_register && !_privacyAccepted) {
      setState(() {
        _privacyError = true;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_register) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final name = _nameController.text.trim();

        if (name.isNotEmpty) {
          try {
            await credential.user?.updateDisplayName(name);
          } catch (_) {}
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      await const EntryPreferences().markCompleted();

      if (!mounted) {
        return;
      }

      context.go('/');
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = _firebaseErrorMessage(error.code);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Não foi possível concluir a operação. '
            'Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_busy) {
      return;
    }

    final validation = _validateEmail(_emailController.text);

    if (validation != null) {
      setState(() {
        _error = 'Digite seu e-mail antes de recuperar a senha.';
      });

      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se o e-mail estiver cadastrado, '
            'você receberá instruções de recuperação.',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = _firebaseErrorMessage(error.code);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Não foi possível solicitar a recuperação.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _continueAsGuest() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
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

      setState(() {
        _error = 'Não foi possível continuar sem conta.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'O endereço de e-mail é inválido.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha escolhida é muito fraca.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Não foi possível conectar ao Firebase.';
      case 'operation-not-allowed':
        return 'Este método de login não está habilitado.';
      default:
        return 'Não foi possível autenticar. Código: $code';
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final colors = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colors.primary, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? colors.infoBackground : const Color(0xFFF4F8F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.veryPoor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.veryPoor, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF071B20) : colors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _AuthHero(register: _register, onBack: _goBack),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 27, 25, 30),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    color: colors.primary,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _register
                                        ? 'COMECE POR AQUI'
                                        : 'ACESSO À SUA CONTA',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _register
                                    ? 'Crie sua conta'
                                    : 'Bem-vindo de volta',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _register
                                    ? 'Salve seus lugares favoritos '
                                          'e acompanhe sua cidade.'
                                    : 'Entre para recuperar suas '
                                          'cidades e preferências.',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_register) ...[
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(color: colors.text),
                                  cursorColor: colors.primary,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  decoration: _fieldDecoration(
                                    label: 'Seu nome',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if ((value?.trim().length ?? 0) < 2) {
                                      return 'Informe seu nome.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                              ],
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(color: colors.text),
                                cursorColor: colors.primary,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                autofillHints: const [AutofillHints.email],
                                decoration: _fieldDecoration(
                                  label: 'E-mail',
                                  icon: Icons.mail_outline,
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                style: TextStyle(color: colors.text),
                                cursorColor: colors.primary,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: [
                                  _register
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: _fieldDecoration(
                                  label: 'Senha',
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: colors.textSecondary,
                                      size: 21,
                                    ),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              if (!_register)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _busy ? null : _resetPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: colors.primary,
                                    ),
                                    child: const Text(
                                      'Esqueci minha senha',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_register)
                                Padding(
                                  padding: const EdgeInsets.only(top: 13),
                                  child: Text(
                                    'A senha precisa ter pelo menos '
                                    '6 caracteres.',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              if (_register) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.infoBackground,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _privacyError
                                          ? colors.veryPoor
                                          : colors.border,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CheckboxListTile(
                                        value: _privacyAccepted,
                                        onChanged: _busy
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _privacyAccepted =
                                                      value ?? false;
                                                  _privacyError = false;
                                                });
                                              },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: colors.primary,
                                        checkColor: colors.onPrimary,
                                        title: Text(
                                          'Li as informações de privacidade '
                                          'e concordo com o uso do meu nome '
                                          'e e-mail para criar a conta e '
                                          'sincronizar meus favoritos e '
                                          'a cidade monitorada no Firebase.',
                                          style: TextStyle(
                                            color: colors.text,
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => context.pushNamed(
                                                'privacidade',
                                              ),
                                        icon: const Icon(
                                          Icons.policy_outlined,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Ler informações de privacidade',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: colors.primary,
                                        ),
                                      ),
                                      if (_privacyError)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            10,
                                            0,
                                            10,
                                            8,
                                          ),
                                          child: Text(
                                            'Marque a opção acima para '
                                            'criar sua conta.',
                                            style: TextStyle(
                                              color: colors.veryPoor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_error != null) ...[
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.veryPoor.withValues(
                                            alpha: 0.12,
                                          )
                                        : const Color(0xFFFFF1F0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? colors.veryPoor.withValues(
                                              alpha: 0.45,
                                            )
                                          : const Color(0xFFF2C9C5),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 19,
                                        color: colors.veryPoor,
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: TextStyle(
                                            color: colors.veryPoor,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 23),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 54,
                                ),
                                child: FilledButton(
                                  onPressed: _busy ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _busy
                                      ? SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            color: colors.onPrimary,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                _register
                                                    ? 'Criar conta'
                                                    : 'Entrar',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 9),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 19,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _busy ? null : _switchMode,
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primary,
                                ),
                                child: Text(
                                  _register
                                      ? 'Já tem uma conta? Entrar'
                                      : 'Ainda não tem conta? Cadastre-se',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 13),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: colors.border),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'ou',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: colors.border),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
                                child: TextButton.icon(
                                  onPressed: _busy ? null : _continueAsGuest,
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 17,
                                  ),
                                  label: const Text(
                                    'Continuar sem conta',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'O Aeris Pulse também funciona '
                                'sem cadastro. Suas preferências '
                                'de visitante permanecem neste dispositivo.',
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

class _AuthHero extends StatelessWidget {
  final bool register;
  final VoidCallback onBack;

  const _AuthHero({required this.register, required this.onBack});

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
              ? const [Color(0xFF071B20), Color(0xFF0B3439)]
              : const [Color(0xFF073D42), AppColors.primary],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _AuthAtmospherePainter()),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 25, 48),
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
                        const SizedBox(width: 6),
                        Image.asset(
                          'assets/images/aeris_logo.png',
                          width: 31,
                          height: 31,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(width: 11),
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
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            register
                                ? 'Suas cidades,\nsempre com você.'
                                : 'Seu ar,\nsempre por perto.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              height: 1.12,
                              letterSpacing: -1.1,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            register
                                ? 'Crie sua conta e mantenha seus '
                                      'lugares favoritos conectados.'
                                : 'Continue de onde parou com seus '
                                      'lugares e preferências salvos.',
                            style: const TextStyle(
                              color: Color(0xFFCAE5DF),
                              fontSize: 13,
                              height: 1.55,
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
        ],
      ),
    );
  }
}

class _AuthAtmospherePainter extends CustomPainter {
  const _AuthAtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    for (var index = 0; index < 5; index++) {
      final path = Path()
        ..moveTo(width * 0.42, -40 + index * 24.0)
        ..cubicTo(
          width * 0.70,
          height * 0.12 + index * 18.0,
          width * 0.63,
          height * 0.64 + index * 10.0,
          width + 50,
          height * 0.48 + index * 18.0,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.055 + index * 0.012)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
    }

    final center = Offset(width * 0.94, height * 0.24);

    for (var index = 0; index < 3; index++) {
      canvas.drawCircle(
        center,
        55 + index * 29.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
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
