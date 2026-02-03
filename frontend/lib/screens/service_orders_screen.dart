import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/order.dart';
import '../providers/user_provider.dart';
import '../services/order_service.dart';
import 'order_details_screen.dart';
import 'create_service_order_screen.dart';

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isLoading = false;
  String? _error;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }
      final list = await OrderService.getAll(token: token);
      setState(() => _orders = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight;
    final orders = _filteredOrders();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Orders')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Service Orders',
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildSearchBar(isDark),
            _buildFilters(isDark),
            Expanded(child: _buildBody(orders, isDark)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateServiceOrderScreen(),
            ),
          ).then((result) {
            if (result == true) _loadOrders();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Order> _filteredOrders() {
    return _orders.where((order) {
      if (_selectedFilter != 'all') {
        final status = _mapStatus(order.status).toLowerCase();
        if (status != _selectedFilter) return false;
      }
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final title = order.equipamento.nome.toLowerCase();
      final clientName = order.cliente?.nome.toLowerCase() ?? '';
      final code = order.equipamento.codigo.toLowerCase();
      return title.contains(q) || clientName.contains(q) || code.contains(q);
    }).toList();
  }

  Widget _buildBody(List<Order> orders, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar ordens',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma ordem encontrada',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search orders',
          filled: true,
          fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final chips = [
      _FilterItem(label: 'All', value: 'all'),
      _FilterItem(label: 'Pending', value: 'pending'),
      _FilterItem(label: 'In Progress', value: 'in progress'),
      _FilterItem(label: 'Overdue', value: 'overdue'),
      _FilterItem(label: 'Completed', value: 'completed'),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = chips[index];
          final isActive = item.value == _selectedFilter;
          return ChoiceChip(
            label: Text(item.label),
            selected: isActive,
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(
              color: isActive
                  ? AppColors.primary
                  : (isDark ? AppColors.slate300 : AppColors.slate600),
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) =>
                setState(() => _selectedFilter = item.value),
            backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: chips.length,
      ),
    );
  }

  String _mapStatus(String raw) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return 'In Progress';
      case 'FINALIZADA':
        return 'Completed';
      case 'ATRASADA':
        return 'Overdue';
      case 'CANCELADA':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}

class _FilterItem {
  final String label;
  final String value;

  _FilterItem({required this.label, required this.value});
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _mapStatus(order.status);
    final location = _buildLocation(order);
    final dueIn = _formatDue(order.dataPrevista);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.build, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.equipamento.nome,
                    style: AppTypography.bodyText.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _chip(order.priority, isDark),
                const SizedBox(width: 8),
                _chip('ID #${order.id}', isDark),
                const Spacer(),
                Text(
                  dueIn,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.slate300 : AppColors.slate600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildLocation(Order order) {
    final equipmentLocation = order.equipamento.localizacao;
    if (equipmentLocation != null && equipmentLocation.isNotEmpty) {
      return equipmentLocation;
    }
    final client = order.cliente;
    if (client == null) return 'Location not specified';
    final parts = [
      if (client.rua != null) client.rua,
      if (client.numero != null) client.numero,
      if (client.bairro != null) client.bairro,
      if (client.cidade != null) client.cidade,
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return 'Location not specified';
    return parts.join(' • ');
  }

  String _formatDue(DateTime? due) {
    if (due == null) return 'No schedule';
    final now = DateTime.now();
    final diff = due.difference(now);
    if (diff.inMinutes < 0) return 'Overdue';
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${diff.inHours} hrs';
    return '${diff.inDays} days';
  }

  Widget _chip(String label, bool isDark) {
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

  String _mapStatus(String raw) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return 'In Progress';
      case 'FINALIZADA':
        return 'Completed';
      case 'ATRASADA':
        return 'Overdue';
      case 'CANCELADA':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (status) {
      case 'Overdue':
        bg = AppColors.statusFailedBg;
        text = AppColors.statusFailedText;
        break;
      case 'In Progress':
        bg = AppColors.statusInProgressBg;
        text = AppColors.statusInProgressText;
        break;
      case 'Completed':
        bg = AppColors.statusCompletedBg;
        text = AppColors.statusCompletedText;
        break;
      default:
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPendingText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTypography.captionSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
