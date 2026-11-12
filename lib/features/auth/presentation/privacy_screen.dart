import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              children: [
                _PrivacyHero(onBack: () => _goBack(context)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(
                        eyebrow: 'TRANSPARÊNCIA',
                        title: 'Como seus dados são utilizados',
                        description:
                            'Conheça as informações envolvidas '
                            'no funcionamento do Aeris Pulse '
                            'e as opções disponíveis para '
                            'gerenciar sua conta.',
                      ),
                      const SizedBox(height: 20),
                      const _PrivacyCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Cadastro e autenticação',
                        paragraphs: [
                          'Ao criar uma conta, você informa '
                              'nome, e-mail e senha. O Aeris Pulse '
                              'utiliza o Firebase Authentication '
                              'para autenticar sua identidade.',
                          'O nome e o e-mail são associados '
                              'à conta. A senha é processada '
                              'pelo serviço de autenticação '
                              'e não é salva nos documentos '
                              'de favoritos ou preferências '
                              'do Firestore.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.cloud_outlined,
                        title: 'Preferências na nuvem',
                        paragraphs: [
                          'Quando você está autenticado, '
                              'suas cidades favoritas e a '
                              'cidade monitorada são armazenadas '
                              'no Cloud Firestore.',
                          'Esses documentos ficam organizados '
                              'por identificador de usuário. '
                              'As regras configuradas exigem '
                              'que a conta autenticada corresponda '
                              'ao identificador do proprietário.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.phone_android_outlined,
                        title: 'Acesso sem cadastro',
                        paragraphs: [
                          'Você pode acompanhar as informações '
                              'ambientais sem criar uma conta.',
                          'No modo visitante, as cidades favoritas '
                              'e a cidade monitorada são mantidas '
                              'em um banco SQLite no dispositivo. '
                              'Essas preferências não são '
                              'sincronizadas automaticamente '
                              'com uma conta.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.storage_outlined,
                        title: 'Cache e funcionamento offline',
                        paragraphs: [
                          'O aplicativo utiliza armazenamento '
                              'local para guardar respostas '
                              'de consultas ambientais e permitir '
                              'a visualização de dados já obtidos '
                              'quando não há conexão disponível.',
                          'O Firebase também pode utilizar '
                              'mecanismos próprios de '
                              'armazenamento temporário. '
                              'A remoção da conta na nuvem '
                              'não significa necessariamente '
                              'que todos os arquivos locais '
                              'do dispositivo sejam apagados.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.public_outlined,
                        title: 'Serviços externos',
                        paragraphs: [
                          'O Aeris Pulse consulta serviços '
                              'externos para buscar cidades '
                              'e obter informações sobre '
                              'qualidade do ar e previsões.',
                          'Essas consultas dependem de '
                              'conexão com a internet. '
                              'Os provedores externos '
                              'podem receber informações '
                              'técnicas necessárias '
                              'à comunicação de rede, '
                              'de acordo com suas próprias '
                              'políticas de privacidade.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.notifications_active_outlined,
                        title: 'Alertas ambientais',
                        paragraphs: [
                          'O aplicativo apresenta alertas '
                              'e indicadores ambientais '
                              'relacionados às cidades '
                              'monitoradas.',
                          'As preferências de apresentação '
                              'dos alertas podem ser ajustadas '
                              'nas configurações. '
                              'A exibição de um alerta '
                              'não substitui orientações '
                              'de órgãos oficiais.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.delete_outline_rounded,
                        title: 'Exclusão de conta e dados',
                        paragraphs: [
                          'Usuários autenticados podem '
                              'solicitar a exclusão da conta '
                              'pela tela Minha conta.',
                          'Após confirmar a identidade '
                              'com a senha, o aplicativo '
                              'tenta remover os favoritos '
                              'e as preferências do Firestore '
                              'antes de excluir a conta '
                              'do Firebase Authentication.',
                          'Se alguma operação falhar, '
                              'o aplicativo apresenta uma '
                              'mensagem de erro. '
                              'Os dados locais do modo '
                              'visitante e o cache ambiental '
                              'não são apagados '
                              'por essa operação.',
                        ],
                      ),
                      const SizedBox(height: 13),
                      const _PrivacyCard(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Controle das suas informações',
                        paragraphs: [
                          'Você pode alterar sua cidade '
                              'monitorada, adicionar ou '
                              'remover cidades favoritas '
                              'e gerenciar sua conta '
                              'pelas funcionalidades '
                              'disponíveis no aplicativo.',
                          'Para remover os dados locais '
                              'do aplicativo, é possível '
                              'utilizar as opções de '
                              'limpeza de armazenamento '
                              'oferecidas pelo sistema '
                              'operacional do dispositivo.',
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.infoBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sobre estas informações',
                                    style: TextStyle(
                                      color: colors.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Este resumo descreve '
                                    'os fluxos de armazenamento '
                                    'e gerenciamento de dados '
                                    'identificados nesta versão '
                                    'do Aeris Pulse.',
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
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _goBack(context),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Voltar ao aplicativo'),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          'Aeris Pulse • Privacidade e transparência',
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

class _PrivacyHero extends StatelessWidget {
  final VoidCallback onBack;

  const _PrivacyHero({required this.onBack});

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
              : const [Color(0xFF073D42), AppColors.primary, Color(0xFF0F6466)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PrivacyAtmospherePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 24, 38),
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
                    const SizedBox(width: 5),
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: 34,
                      height: 34,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Aeris Pulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 43),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.breeze),
                    SizedBox(width: 9),
                    Text(
                      'SEUS DADOS IMPORTAM',
                      style: TextStyle(
                        color: AppColors.breeze,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Privacidade\nem primeiro lugar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                    height: 1.13,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Transparência sobre as informações '
                  'utilizadas para personalizar '
                  'sua experiência ambiental.',
                  style: TextStyle(
                    color: Color(0xFFD2E8E4),
                    fontSize: 13,
                    height: 1.6,
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
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          description,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> paragraphs;

  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.paragraphs,
  });

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
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: colors.infoBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 22, color: colors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          for (var index = 0; index < paragraphs.length; index++) ...[
            if (index > 0) const SizedBox(height: 11),
            Text(
              paragraphs[index],
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.65,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyAtmospherePainter extends CustomPainter {
  const _PrivacyAtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    for (var index = 0; index < 6; index++) {
      final shift = index * 23.0;

      final path = Path()
        ..moveTo(width * 0.35, -50 + shift)
        ..cubicTo(
          width * 0.72,
          height * 0.05 + shift,
          width * 0.63,
          height * 0.55 + shift,
          width + 50,
          height * 0.32 + shift,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.035 + index * 0.009)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
    }

    final center = Offset(width * 0.94, height * 0.2);

    for (var index = 0; index < 4; index++) {
      canvas.drawCircle(
        center,
        48 + index * 26.0,
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
