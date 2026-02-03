import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'create_client_screen.dart';
import '../providers/user_provider.dart';
import '../services/cliente_service.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _clients = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final list = await ClienteService.listarClientes(token: token);
      setState(() {
        _clients = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDefaultDark : AppColors.borderLight;
    final clients = _clients.where((c) {
      final type = (c['tipo'] ?? '').toString().toLowerCase();
      if (_selectedFilter == 'all') return true;
      return type == _selectedFilter;
    }).where((c) {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) return true;
      final name = (c['nome'] ?? '').toString().toLowerCase();
      final email = (c['email'] ?? '').toString().toLowerCase();
      final documento = (c['documento'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          documento.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateClientScreen(),
                ),
              ).then((result) {
                if (result == true) _loadClients();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Client Directory',
                style: AppTypography.headline3.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _filterTab('All', 'all', isDark),
                  _filterTab('Individual', 'individual', isDark),
                  _filterTab('Corporate', 'corporate', isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(clients, isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClientScreen(),
            ),
          ).then((result) {
            if (result == true) _loadClients();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> clients, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar clientes',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    if (clients.isEmpty) {
      return Center(
        child: Text(
          'Nenhum cliente encontrado',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ClientCard(client: clients[index]);
      },
    );
  }

  Widget _filterTab(String label, String value, bool isDark) {
    final isActive = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.slate900 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isActive
                  ? AppColors.primary
                  : (isDark ? AppColors.slate300 : AppColors.slate600),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

}

class _ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = (client['nome'] ?? '').toString();
    final email = (client['email'] ?? '').toString();
    final type = (client['tipo'] ?? '').toString().toLowerCase();
    final typeLabel = type == 'corporate' ? 'Corporate' : 'Individual';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Sem nome' : name,
                  style: AppTypography.bodyText.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'Sem email' : email,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          _TypeChip(label: typeLabel),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;

  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: isDark ? AppColors.slate200 : AppColors.slate600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
