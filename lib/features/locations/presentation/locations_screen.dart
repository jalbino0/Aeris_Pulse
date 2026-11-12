import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../data/brazilian_city.dart';
import '../providers/locations_provider.dart';
import '../providers/selected_city_provider.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  final _searchController = TextEditingController();
  final Set<int> _busyFavorites = {};

  Timer? _debounce;
  String _query = '';
  int? _selectingCityId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final term = value.trim();

    if (term.length < 3) {
      setState(() {
        _query = '';
      });
      return;
    }

    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted && _searchController.text.trim() == term) {
        setState(() {
          _query = term;
        });
      }
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _selectCity(BrazilianCity city) async {
    if (_selectingCityId != null) return;

    setState(() {
      _selectingCityId = city.id;
    });

    try {
      await ref.read(selectedCityProvider.notifier).select(city);
      _showMessage(
        '${city.name} selecionada. Os dados ambientais serão atualizados.',
      );
    } catch (_) {
      _showMessage('Não foi possível selecionar a cidade.');
    } finally {
      if (mounted) {
        setState(() {
          _selectingCityId = null;
        });
      }
    }
  }

  Future<void> _toggleFavorite(BrazilianCity city, bool isFavorite) async {
    if (_busyFavorites.contains(city.id)) return;

    setState(() {
      _busyFavorites.add(city.id);
    });

    try {
      final repository = ref.read(cityFavoritesRepositoryProvider);

      if (isFavorite) {
        await repository.removeFavorite(city.id);
      } else {
        await repository.addFavorite(city);
      }

      if (!mounted) return;

      ref.invalidate(favoriteCitiesProvider);
      _showMessage(
        isFavorite
            ? '${city.name} removida dos favoritos.'
            : '${city.name} adicionada aos favoritos.',
      );
    } catch (_) {
      _showMessage('Não foi possível alterar os favoritos.');
    } finally {
      if (mounted) {
        setState(() {
          _busyFavorites.remove(city.id);
        });
      }
    }
  }

  Widget _cityCard(BrazilianCity city, Set<int> favoriteIds, int? selectedId) {
    final colors = AppTheme.paletteOf(context);
    final isSelected = selectedId == city.id;
    final isFavorite = favoriteIds.contains(city.id);
    final selecting = _selectingCityId == city.id;
    final favoriteBusy = _busyFavorites.contains(city.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isSelected ? colors.primary : colors.border,
          width: isSelected ? 1.5 : 1,
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : colors.infoBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isSelected
                  ? Icons.check_circle_outline_rounded
                  : Icons.location_city_outlined,
              color: isSelected ? colors.onPrimary : colors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${city.state} • Brasil',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 7),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: colors.good),
                      const SizedBox(width: 6),
                      Text(
                        'Monitorando agora',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: isSelected
                ? 'Cidade monitorada'
                : 'Monitorar ${city.name}',
            onPressed: isSelected || _selectingCityId != null
                ? null
                : () => _selectCity(city),
            icon: selecting
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: colors.primary,
                    size: 23,
                  ),
          ),
          IconButton(
            tooltip: isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: favoriteBusy
                ? null
                : () => _toggleFavorite(city, isFavorite),
            icon: favoriteBusy
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_add_outlined,
                    color: colors.primary,
                    size: 24,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);
    final selectedState = ref.watch(selectedCityProvider);
    final selectedCity = selectedState.asData?.value;

    final favoritesState = ref.watch(favoriteCitiesProvider);
    final favorites = favoritesState.asData?.value ?? [];
    final favoriteIds = favorites.map((city) => city.id).toSet();

    final searchState = _query.isEmpty
        ? null
        : ref.watch(citySearchProvider(_query));
    final results = searchState?.asData?.value ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.zero,
              children: [
                _LocationsHero(
                  cityName: selectedCity?.name,
                  cityState: selectedCity?.state,
                  cityLoading: selectedState.isLoading,
                  favoriteCount: favoritesState.isLoading
                      ? null
                      : favorites.length,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 29, 20, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedState.hasError) ...[
                        const _StatusCard(
                          icon: Icons.error_outline_rounded,
                          title: 'Cidade indisponível',
                          description:
                              'Não foi possível carregar a cidade monitorada.',
                        ),
                        const SizedBox(height: 22),
                      ],
                      const _SectionHeading(
                        eyebrow: 'EXPLORE O BRASIL',
                        title: 'Encontre sua cidade',
                        description:
                            'Busque uma localidade para acompanhar suas '
                            'condições ambientais ou salvá-la nos favoritos.',
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Ex.: Campinas, Recife, Curitiba',
                          hintStyle: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: colors.primary,
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar busca',
                                  onPressed: _clearSearch,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: colors.textSecondary,
                                  ),
                                ),
                          filled: true,
                          fillColor: colors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 17,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colors.primary,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Digite pelo menos 3 caracteres.',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (_query.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Expanded(
                              child: _SectionHeading(
                                eyebrow: 'PESQUISA',
                                title: 'Resultados encontrados',
                              ),
                            ),
                            if (searchState?.isLoading == true)
                              SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (searchState?.hasError == true) ...[
                          const _StatusCard(
                            icon: Icons.wifi_off_outlined,
                            title: 'Busca indisponível',
                            description: 'Verifique a conexão. Os favoritos continuam salvos.',
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                ref.invalidate(citySearchProvider(_query)),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                          ),
                        ] else if (searchState?.isLoading == true &&
                            results.isEmpty)
                          const _StatusCard(
                            icon: Icons.search_rounded,
                            title: 'Procurando cidades',
                            description:
                                'Consultando localidades brasileiras...',
                            loading: true,
                          )
                        else if (searchState?.hasValue == true &&
                            results.isEmpty)
                          const _StatusCard(
                            icon: Icons.search_off_outlined,
                            title: 'Nenhuma cidade encontrada',
                            description: 'Tente outro nome ou outra grafia.',
                          )
                        else
                          for (final city in results)
                            _cityCard(city, favoriteIds, selectedCity?.id),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Expanded(
                            child: _SectionHeading(
                              eyebrow: 'SEUS LUGARES',
                              title: 'Cidades favoritas',
                              description: 'Acesse rapidamente as cidades que você salvou.',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.infoBackground,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              favoritesState.isLoading
                                  ? '—'
                                  : '${favorites.length}',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (favoritesState.isLoading && favorites.isEmpty)
                        const _StatusCard(
                          icon: Icons.bookmark_outline_rounded,
                          title: 'Carregando favoritos',
                          description: 'Recuperando suas cidades salvas.',
                          loading: true,
                        )
                      else if (favoritesState.hasError && favorites.isEmpty)
                        const _StatusCard(
                          icon: Icons.error_outline_rounded,
                          title: 'Favoritos indisponíveis',
                          description:
                              'Não foi possível recuperar as cidades salvas.',
                        )
                      else if (favorites.isEmpty)
                        const _StatusCard(
                          icon: Icons.bookmark_add_outlined,
                          title: 'Nenhum favorito ainda',
                          description:
                              'Pesquise uma cidade e toque no marcador '
                              'para encontrá-la novamente, mesmo offline.',
                        )
                      else
                        for (final city in favorites)
                          _cityCard(city, favoriteIds, selectedCity?.id),
                      const SizedBox(height: 18),
                      const _InformationCard(
                        title: 'Sobre os dados das cidades',
                        message:
                            'Ao trocar a cidade monitorada, o Aeris Pulse '
                            'atualiza as consultas ambientais e utiliza '
                            'caches separados no SQLite. As concentrações '
                            'são estimativas do modelo CAMS, não medições '
                            'locais. Os horários seguem a referência de Brasília.',
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

class _LocationsHero extends StatelessWidget {
  final String? cityName;
  final String? cityState;
  final bool cityLoading;
  final int? favoriteCount;

  const _LocationsHero({
    required this.cityName,
    required this.cityState,
    required this.cityLoading,
    required this.favoriteCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
              child: CustomPaint(painter: _LocationsAtmospherePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 29),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/aeris_logo.png',
                      width: 38,
                      height: 38,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 10),
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
                        Icons.public_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 37),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: AppColors.breeze),
                    SizedBox(width: 9),
                    Text(
                      'SUAS LOCALIDADES',
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
                  'Seu mundo,\nseu ar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Escolha os lugares que importam e acompanhe '
                  'as condições atmosféricas de cada cidade.',
                  style: TextStyle(
                    color: Color(0xFFD3E8E5),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 25),
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
                            Icons.location_on_outlined,
                            color: AppColors.breeze,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CIDADE MONITORADA',
                            style: TextStyle(
                              color: AppColors.breeze,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (cityLoading && cityName == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: CircularProgressIndicator(
                            color: AppColors.breeze,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Text(
                          cityName ?? 'Cidade indisponível',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.7,
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        cityState == null
                            ? 'Aguardando localidade'
                            : '$cityState • Brasil',
                        style: const TextStyle(
                          color: Color(0xFFCAE5DF),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
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
                              Icons.bookmark_outline_rounded,
                              color: AppColors.breeze,
                              size: 18,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                favoriteCount == null
                                    ? 'Carregando seus favoritos...'
                                    : '$favoriteCount ${favoriteCount == 1 ? 'cidade favorita' : 'cidades favoritas'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'As consultas ambientais utilizam '
                        'a cidade monitorada acima.',
                        style: TextStyle(
                          color: Color(0xFFC8E1DC),
                          fontSize: 11,
                          height: 1.5,
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

class _LocationsAtmospherePainter extends CustomPainter {
  const _LocationsAtmospherePainter();

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.description,
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
            letterSpacing: -0.65,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 7),
          Text(
            description!,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool loading;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.description,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          if (loading)
            CircularProgressIndicator(color: colors.primary)
          else
            Icon(icon, color: colors.primary, size: 35),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final String title;
  final String message;

  const _InformationCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.paletteOf(context);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.primary, size: 21),
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
                  message,
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
