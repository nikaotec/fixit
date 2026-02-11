import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/firestore_technician_service.dart';
import '../models/technician.dart';
import 'technician_profile_screen.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _inputQuery = '';
  String _filter = 'all';
  bool _isLoading = false;
  String? _error;
  List<Technician> _technicians = [];
  List<Technician> _searchResults = [];
  List<Technician> _cachedFavorites = [];
  Set<String> _favoriteIds = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCachedFavorites();
    _loadTechnicians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No longer need token check
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.backgroundDarkTheme
        : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDarkTheme : Colors.white;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;
    final text = isDark ? Colors.white : AppColors.textPrimary;
    final subtitle = isDark ? AppColors.slate300 : AppColors.slate600;

    final list = _filteredTechnicians();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Técnicos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipe técnica',
                        style: AppTypography.headline3.copyWith(
                          color: text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Busque por nome ou e-mail e favorite técnicos da plataforma.',
                        style: AppTypography.caption.copyWith(color: subtitle),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_technicians.length} técnicos',
                    style: AppTypography.captionSmall.copyWith(
                      color: subtitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _inputQuery = value);
                if (value.trim().isEmpty && _query.isNotEmpty) {
                  setState(() => _query = '');
                  _loadTechnicians();
                }
              },
              onSubmitted: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail (mín. 3 letras)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_inputQuery.trim().isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _inputQuery = '';
                            _query = '';
                          });
                          _loadTechnicians();
                        },
                        tooltip: 'Limpar',
                        icon: const Icon(Icons.close),
                      ),
                    IconButton(
                      onPressed: _applySearch,
                      tooltip: 'Pesquisar',
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                filled: true,
                fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _buildFilters(isDark),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTechnicians,
              child: _buildBody(
                list: list,
                isDark: isDark,
                surface: surface,
                border: border,
                text: text,
                subtitle: subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final filters = const [
      _FilterItem(label: 'Todos', value: 'all'),
      _FilterItem(label: 'Favoritos (global)', value: 'favorites'),
      _FilterItem(label: 'Disponível', value: 'available'),
      _FilterItem(label: 'Ocupado', value: 'busy'),
      _FilterItem(label: 'Offline', value: 'offline'),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = filters[index];
          final selected = item.value == _filter;
          return ChoiceChip(
            label: Text(item.label),
            selected: selected,
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.slate300 : AppColors.slate600),
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => setState(() => _filter = item.value),
            backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }

  List<Technician> _filteredTechnicians() {
    final baseList = _filter == 'favorites'
        ? _buildFavoritesList()
        : (_isSearching ? _searchResults : <Technician>[]);

    final filtered = baseList.where((tech) {
      if (_filter == 'favorites') {
        if (!_favoriteIds.contains(tech.id)) return false;
        return true;
      } else if (_filter != 'all' && tech.status.value != _filter) {
        return false;
      }
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return tech.name.toLowerCase().contains(q) ||
          (tech.email?.toLowerCase().contains(q) ?? false);
    }).toList();
    filtered.sort((a, b) {
      final aFav = _favoriteIds.contains(a.id);
      final bFav = _favoriteIds.contains(b.id);
      if (aFav != bFav) return aFav ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return filtered;
  }

  List<Technician> _buildFavoritesList() {
    final byId = <String, Technician>{};
    for (final tech in _cachedFavorites) {
      if (_favoriteIds.contains(tech.id)) byId[tech.id] = tech;
    }
    for (final tech in _technicians) {
      if (_favoriteIds.contains(tech.id)) byId[tech.id] = tech;
    }
    for (final tech in _searchResults) {
      if (_favoriteIds.contains(tech.id)) byId[tech.id] = tech;
    }
    return byId.values.toList();
  }

  void _applySearch() {
    final raw = _inputQuery.trim();
    if (raw.isEmpty) {
      setState(() {
        _query = '';
        _isSearching = false;
      });
      return;
    }
    if (raw.length < 3) {
      _showSnack('Digite pelo menos 3 letras para pesquisar');
      return;
    }
    setState(() {
      _query = raw;
      _isSearching = true;
    });
    _searchTechnicians(raw);
  }

  Future<void> _searchTechnicians(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await FirestoreTechnicianService.search(query: query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      _showSnack('Erro ao pesquisar técnicos');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBody({
    required List<Technician> list,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color text,
    required Color subtitle,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar técnicos',
          style: AppTypography.bodyText.copyWith(color: subtitle),
        ),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Text(
          'Nenhum técnico encontrado',
          style: AppTypography.bodyText.copyWith(color: subtitle),
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final tech = list[index];
        final isExternal = !_technicians.any((t) => t.id == tech.id);
        return _TechnicianCard(
          tech: tech,
          surface: surface,
          border: border,
          text: text,
          subtitle: subtitle,
          isDark: isDark,
          isFavorite: _favoriteIds.contains(tech.id),
          isExternal: isExternal,
          onFavorite: () => _toggleFavorite(tech),
          onCall: () => _showSnack('Em breve: chamada'),
          onProfile: () => _openProfile(tech),
          onAssign: () => _showSnack('Em breve: atribuir ordem'),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openProfile(Technician tech) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicianProfileScreen(
          technician: tech,
          onCall: () => _showSnack('Em breve: chamada'),
          onAssign: () => _showSnack('Em breve: atribuir ordem'),
        ),
      ),
    );
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final currentUserId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).id;
      final results = await Future.wait([
        FirestoreTechnicianService.getAll(),
        FirestoreTechnicianService.getFavorites(),
        FirestoreTechnicianService.getFavoriteDetails(),
      ]);
      final list = (results[0] as List<Technician>)
          .where((tech) => tech.id != currentUserId)
          .toList();
      final favoriteDetails = results[2] as List<Technician>;
      final favoriteIds = results[1] as Set<String>;
      setState(() {
        _technicians = list;
        _favoriteIds = favoriteIds;
        if (favoriteDetails.isNotEmpty || favoriteIds.isEmpty) {
          _cachedFavorites = favoriteDetails;
        }
      });
      if (favoriteDetails.isNotEmpty || favoriteIds.isEmpty) {
        await FirestoreTechnicianService.saveCachedFavorites(favoriteDetails);
      }
      await _refreshCachedFavorites();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(Technician tech) async {
    final isFavorite = _favoriteIds.contains(tech.id);
    setState(() {
      if (isFavorite) {
        _favoriteIds.remove(tech.id);
      } else {
        _favoriteIds.add(tech.id);
      }
    });
    await _updateCachedFavorites(tech: tech, isFavorite: !isFavorite);
    try {
      final updated = await FirestoreTechnicianService.setFavorite(
        technicianId: tech.id,
        isFavorite: !isFavorite,
      );
      if (!mounted) return;
      setState(() => _favoriteIds = updated);
      await _refreshCachedFavorites();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isFavorite) {
          _favoriteIds.add(tech.id);
        } else {
          _favoriteIds.remove(tech.id);
        }
      });
      await _updateCachedFavorites(tech: tech, isFavorite: isFavorite);
      _showSnack('Não foi possível salvar o favorito');
    }
  }

  Future<void> _loadCachedFavorites() async {
    final cached = await FirestoreTechnicianService.loadCachedFavorites();
    if (!mounted) return;
    setState(() {
      _cachedFavorites = cached;
      if (_favoriteIds.isEmpty && cached.isNotEmpty) {
        _favoriteIds = cached.map((t) => t.id).toSet();
      }
    });
  }

  Future<void> _updateCachedFavorites({
    required Technician tech,
    required bool isFavorite,
  }) async {
    final updated = List<Technician>.from(_cachedFavorites);
    if (isFavorite) {
      final exists = updated.any((t) => t.id == tech.id);
      if (!exists) updated.add(tech);
    } else {
      updated.removeWhere((t) => t.id == tech.id);
    }
    if (!mounted) return;
    setState(() => _cachedFavorites = updated);
    await FirestoreTechnicianService.saveCachedFavorites(updated);
  }

  Future<void> _refreshCachedFavorites() async {
    if (_favoriteIds.isEmpty) return;
    final updated = _buildFavoritesList();
    if (!mounted) return;
    setState(() => _cachedFavorites = updated);
    await FirestoreTechnicianService.saveCachedFavorites(updated);
  }
}

class _TechnicianCard extends StatelessWidget {
  final Technician tech;
  final Color surface;
  final Color border;
  final Color text;
  final Color subtitle;
  final bool isDark;
  final bool isFavorite;
  final bool isExternal;
  final VoidCallback? onFavorite;
  final VoidCallback? onCall;
  final VoidCallback? onProfile;
  final VoidCallback? onAssign;

  const _TechnicianCard({
    required this.tech,
    required this.surface,
    required this.border,
    required this.text,
    required this.subtitle,
    required this.isDark,
    required this.isFavorite,
    required this.isExternal,
    this.onFavorite,
    this.onCall,
    this.onProfile,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = tech.status.color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onProfile,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: statusColor.withOpacity(0.15),
                    backgroundImage: tech.avatarUrl != null
                        ? NetworkImage(tech.avatarUrl!)
                        : null,
                    child: tech.avatarUrl == null
                        ? Text(
                            tech.name.isNotEmpty ? tech.name[0] : '?',
                            style: AppTypography.subtitle2.copyWith(
                              color: statusColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tech.name,
                          style: AppTypography.bodyText.copyWith(
                            color: text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tech.role,
                          style: AppTypography.caption.copyWith(
                            color: subtitle,
                          ),
                        ),
                        if (tech.email != null && tech.email!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            tech.email!,
                            style: AppTypography.captionSmall.copyWith(
                              color: subtitle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusBadge(status: tech.status),
                      if (isExternal) ...[
                        const SizedBox(height: 6),
                        _TagBadge(label: 'Plataforma', isDark: isDark),
                      ],
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          size: 18,
                          color: isFavorite ? AppColors.warning : null,
                        ),
                        tooltip: isFavorite
                            ? 'Remover favorito'
                            : 'Adicionar favorito',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (tech.rating > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            tech.rating.toStringAsFixed(1),
                            style: AppTypography.captionSmall.copyWith(
                              color: subtitle,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (tech.reviewCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${tech.reviewCount} avaliações',
                        style: AppTypography.captionSmall.copyWith(
                          color: subtitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${tech.completed} tarefas',
                      style: AppTypography.captionSmall.copyWith(
                        color: subtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onProfile,
                    icon: const Icon(Icons.person_outline, size: 18),
                    tooltip: 'Perfil',
                  ),
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(Icons.call_outlined, size: 18),
                    tooltip: 'Ligar',
                  ),
                  IconButton(
                    onPressed: onAssign,
                    icon: const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 18,
                    ),
                    tooltip: 'Atribuir',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TechnicianStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTypography.captionSmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const _TagBadge({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final background = isDark ? AppColors.slate800 : AppColors.slate100;
    final text = isDark ? AppColors.slate200 : AppColors.slate700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterItem {
  final String label;
  final String value;

  const _FilterItem({required this.label, required this.value});
}
