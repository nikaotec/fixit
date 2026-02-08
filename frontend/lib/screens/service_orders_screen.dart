import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../providers/user_provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/order_event_utils.dart';
import 'order_details_screen.dart';
import 'create_service_order_screen.dart';

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key, this.isActive = false});

  final bool isActive;

  @override
  State<ServiceOrdersScreen> createState() => ServiceOrdersScreenState();
}

class ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isLoading = false;
  String? _error;
  List<Order> _orders = [];
  String? _lastToken;
  WebSocketChannel? _ordersChannel;
  StreamSubscription? _ordersSub;
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _updatePolling();
  }

  void refreshOrders() {
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<UserProvider>(context).token;
    if (token != null && token != _lastToken) {
      _lastToken = token;
      _connectRealtime(token);
      _loadOrders();
    }
  }

  @override
  void didUpdateWidget(covariant ServiceOrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _updatePolling();
      if (widget.isActive) {
        _loadOrders(showLoading: false);
      }
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _ordersSub?.cancel();
    _ordersChannel?.sink.close();
    super.dispose();
  }

  void _updatePolling() {
    if (widget.isActive) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted || _isLoading) return;
      _loadOrders(showLoading: false);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _connectRealtime(String token) {
    _ordersSub?.cancel();
    _ordersChannel?.sink.close();
    final url = '${ApiService.wsBaseUrl}/ws/orders?token=$token';
    _ordersChannel = IOWebSocketChannel.connect(Uri.parse(url));
    _ordersSub = _ordersChannel!.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is Map && OrderEventUtils.isOrderEvent(data)) {
          _handleOrderEvent(data);
        }
      } catch (_) {
        // ignore malformed events
      }
    });
  }

  Future<void> _handleOrderEvent(Map data) async {
    final orderId = OrderEventUtils.extractOrderId(data);
    if (orderId == null) return;
    if (OrderEventUtils.isDeleteEvent(data)) {
      if (!mounted) return;
      setState(() {
        _orders.removeWhere((order) => order.id == orderId);
      });
      return;
    }
    final payload = OrderEventUtils.extractOrderPayload(data);
    if (payload != null) {
      final updated = Order.fromJson(payload);
      _upsertOrder(updated);
      return;
    }
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final updated = await OrderService.getById(token: token, id: orderId);
      _upsertOrder(updated);
    } catch (_) {}
  }

  void _upsertOrder(Order updated) {
    if (!mounted) return;
    setState(() {
      final index = _orders.indexWhere((order) => order.id == updated.id);
      if (index >= 0) {
        _orders[index] = updated;
      } else {
        _orders.insert(0, updated);
      }
    });
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final list = await OrderService.getAll(token: token);
      if (!mounted) return;
      setState(() {
        _orders = list;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (showLoading && mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentUserId =
        int.tryParse(Provider.of<UserProvider>(context).id ?? '');
    final background =
        isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight;
    final orders = _filteredOrders();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.serviceOrdersTitle,
                  style: AppTypography.headline3.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildSearchBar(isDark, l10n),
            _buildFilters(isDark, l10n),
            Expanded(child: _buildBody(orders, isDark, l10n, currentUserId)),
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
        final status = _statusKey(order.status);
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

  Widget _buildBody(
    List<Order> orders,
    bool isDark,
    AppLocalizations l10n,
    int? currentUserId,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          l10n.ordersLoadError,
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    if (orders.isEmpty) {
      return Center(
        child: Text(
          l10n.noOrdersFound,
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
          statusColor: _statusColor(order.status, isDark),
          roleLabel: _roleLabelForOrder(order, currentUserId, l10n),
          statusLabel: _statusLabel(order.status, l10n),
          locationNotSpecified: l10n.locationNotSpecified,
          noScheduleLabel: l10n.noSchedule,
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

  String? _roleLabelForOrder(
    Order order,
    int? currentUserId,
    AppLocalizations l10n,
  ) {
    if (currentUserId == null) return null;
    final isCreator = order.criador?.id == currentUserId;
    final isResponsible = order.responsavel?.id == currentUserId;
    if (isCreator && isResponsible) return l10n.roleCreatorResponsible;
    if (isCreator) return l10n.roleCreator;
    if (isResponsible) return l10n.roleResponsible;
    return null;
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: l10n.searchOrdersPlaceholder,
          filled: true,
          fillColor: isDark ? AppColors.slate800 : AppColors.slate50,
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark, AppLocalizations l10n) {
    final chips = [
      _FilterItem(label: l10n.all, value: 'all'),
      _FilterItem(label: l10n.statusPending, value: 'pending'),
      _FilterItem(label: l10n.statusInProgress, value: 'in_progress'),
      _FilterItem(label: l10n.statusOverdue, value: 'overdue'),
      _FilterItem(label: l10n.statusFinished, value: 'completed'),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = chips[index];
          final isActive = item.value == _selectedFilter;
          final statusColor = _filterColor(item.value, isDark);
          return ChoiceChip(
            label: Text(item.label),
            selected: isActive,
            selectedColor: statusColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: isActive
                  ? statusColor
                  : statusColor.withOpacity(isDark ? 0.7 : 0.9),
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

  Color _filterColor(String value, bool isDark) {
    switch (value) {
      case 'completed':
        return isDark
            ? AppColors.statusCompletedTextDark
            : AppColors.statusCompletedText;
      case 'overdue':
        return isDark
            ? AppColors.statusFailedTextDark
            : AppColors.statusFailedText;
      case 'in_progress':
        return isDark
            ? AppColors.statusInProgressTextDark
            : AppColors.statusInProgressText;
      case 'pending':
        return isDark
            ? AppColors.statusPendingTextDark
            : AppColors.statusPendingText;
      default:
        return isDark ? Colors.white : AppColors.textPrimary;
    }
  }

  String _statusKey(String raw) {
    switch (raw) {
      case 'EM_ANDAMENTO':
        return 'in_progress';
      case 'FINALIZADA':
        return 'completed';
      case 'ATRASADA':
        return 'overdue';
      case 'CANCELADA':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  String _statusLabel(String raw, AppLocalizations l10n) {
    switch (_statusKey(raw)) {
      case 'in_progress':
        return l10n.statusInProgress;
      case 'completed':
        return l10n.statusFinished;
      case 'overdue':
        return l10n.statusOverdue;
      case 'cancelled':
        return l10n.statusCancelled;
      default:
        return l10n.statusPending;
    }
  }

  Color _statusColor(String raw, bool isDark) {
    switch (raw) {
      case 'FINALIZADA':
        return isDark
            ? AppColors.statusCompletedTextDark
            : AppColors.statusCompletedText;
      case 'ATRASADA':
      case 'CANCELADA':
        return isDark
            ? AppColors.statusFailedTextDark
            : AppColors.statusFailedText;
      case 'EM_ANDAMENTO':
        return isDark
            ? AppColors.statusInProgressTextDark
            : AppColors.statusInProgressText;
      default:
        return isDark
            ? AppColors.statusPendingTextDark
            : AppColors.statusPendingText;
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
  final Color statusColor;
  final String? roleLabel;
  final String statusLabel;
  final String locationNotSpecified;
  final String noScheduleLabel;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.statusColor,
    this.roleLabel,
    required this.statusLabel,
    required this.locationNotSpecified,
    required this.noScheduleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = statusLabel;
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
            color: statusColor.withOpacity(isDark ? 0.35 : 0.25),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: statusColor.withOpacity(0.25),
                    blurRadius: 14,
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
                _StatusChip(status: status),
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
                if (roleLabel != null) ...[
                  _roleChip(roleLabel!, isDark),
                  const SizedBox(width: 8),
                ],
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

  Widget _roleChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: isDark ? AppColors.slate200 : AppColors.slate700,
          fontWeight: FontWeight.w600,
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
    if (client == null) return locationNotSpecified;
    final parts = [
      if (client.rua != null) client.rua,
      if (client.numero != null) client.numero,
      if (client.bairro != null) client.bairro,
      if (client.cidade != null) client.cidade,
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return locationNotSpecified;
    return parts.join(' • ');
  }

  String _formatDue(DateTime? due) {
    if (due == null) return noScheduleLabel;
    final now = DateTime.now();
    final diff = due.difference(now);
    if (diff.inMinutes < 0) return statusLabel;
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inDays < 1) return '${diff.inHours} h';
    return '${diff.inDays} dias';
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

}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    final normalized = status.toLowerCase();
    if (normalized.contains('atras')) {
        bg = AppColors.statusFailedBg;
        text = AppColors.statusFailedText;
    } else if (normalized.contains('andamento')) {
        bg = AppColors.statusInProgressBg;
        text = AppColors.statusInProgressText;
    } else if (normalized.contains('conclu') ||
        normalized.contains('finaliz')) {
        bg = AppColors.statusCompletedBg;
        text = AppColors.statusCompletedText;
    } else {
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPendingText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTypography.captionSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
