import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_typography.dart';
import 'order_details_screen.dart';
import 'profile_screen.dart';
import 'inventory_screen.dart';
import 'notifications_screen.dart';
import 'service_orders_screen.dart';
import 'clients_list_screen.dart';
import 'checklist_templates_screen.dart';
import 'create_service_order_screen.dart';
import 'technicians_screen.dart';
import '../models/order.dart';
import '../providers/user_provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/order_event_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoadingOrders = false;
  String? _ordersError;
  List<Order> _orders = [];
  String? _lastToken;
  final GlobalKey<ServiceOrdersScreenState> _ordersKey =
      GlobalKey<ServiceOrdersScreenState>();
  WebSocketChannel? _ordersChannel;
  StreamSubscription? _ordersSub;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _ordersSub?.cancel();
    _ordersChannel?.sink.close();
    super.dispose();
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
      _applyRealtimeOrder(updated);
      return;
    }
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final updated = await OrderService.getById(token: token, id: orderId);
      _applyRealtimeOrder(updated);
    } catch (e) {
      _handleOrderFetchError(orderId, e);
    }
  }

  void _applyRealtimeOrder(Order updated) {
    final currentUserId =
        int.tryParse(Provider.of<UserProvider>(context, listen: false).id ?? '');
    if (_isOrderRelevant(updated, currentUserId)) {
      _upsertOrder(updated);
      return;
    }
    if (!mounted) return;
    setState(() {
      _orders.removeWhere((order) => order.id == updated.id);
    });
  }

  void _handleOrderFetchError(int orderId, Object error) {
    final raw = error.toString();
    if (!raw.contains('401') &&
        !raw.contains('403') &&
        !raw.contains('404')) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _orders.removeWhere((order) => order.id == orderId);
    });
  }

  bool _isOrderRelevant(Order order, int? currentUserId) {
    if (currentUserId == null) return true;
    final isCreator = order.criador?.id == currentUserId;
    final isResponsible = order.responsavel?.id == currentUserId;
    return isCreator || isResponsible;
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

  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final list = await OrderService.getAll(token: token);
      setState(() => _orders = list);
    } catch (e) {
      setState(() => _ordersError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingOrders = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = int.tryParse(userProvider.id ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDarkTheme
        : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDarkTheme
        : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.borderDefaultDark
        : AppColors.borderLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textTertiary;
    final stats = _buildStats();
    final recentOrders = _recentOrders();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(
                    context,
                    isDark,
                    textSecondaryColor,
                    textColor,
                    borderColor,
                    l10n,
                    userProvider.name ?? 'Global Tech Solutions',
                  ),

                  // Stats Section
                  _buildStatsSection(
                    context,
                    isDark,
                    surfaceColor,
                    borderColor,
                    textColor,
                    textSecondaryColor,
                    l10n,
                    stats,
                  ),

                  // Quick Actions
                  _buildQuickActions(
                    context,
                    isDark,
                    surfaceColor,
                    borderColor,
                    textColor,
                    l10n,
                  ),

                  // Recent Service Orders
                  _buildRecentOrders(
                    context,
                    isDark,
                    surfaceColor,
                    borderColor,
                    textColor,
                    textSecondaryColor,
                    l10n,
                    recentOrders,
                    currentUserId,
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
            // Tab 1 (Orders)
            ServiceOrdersScreen(
              key: _ordersKey,
              isActive: _selectedIndex == 1,
            ),
            // Tab 2 (Inventory)
            const InventoryScreen(),
            // Tab 3 (Notifications)
            const NotificationsScreen(),
            // Tab 4 (Settings)
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        isDark,
        surfaceColor,
        borderColor,
        l10n,
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color textSecondaryColor,
    Color textColor,
    Color borderColor,
    AppLocalizations l10n,
    String companyLabel,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDarkTheme
            : AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuC0JyGIBwMgPDUazXA3m9awNDpvKXwvEGmPt3sv7kTgj3j-g7U5c8Ehfke8N_rIHR3EzIz2fEiKR3GXuCoyAiz77RAs1QPghgCkKbfeZOupZ7Ma6iEBvJiWaHEuJ2VJYtTvvrid-smXqyFHHWGgphiap7sgNFjGLQ8XcVdWlh6fcUAqeLbND6N0VMdxXGgypOVEdU-0jC6glJrADSY4i4IbGPXRdmyoLfKV9NKzDOfYQfL9OintehvzikLxTIVtiL4gkIPhsagnNVg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mainDashboard,
                    style: AppTypography.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    companyLabel,
                    style: AppTypography.captionSmall.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: textColor,
                  size: 24,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l10n,
    Map<String, _StatusStats> stats,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            l10n.statusOpen,
            (stats['open']?.count ?? 0).toString(),
            stats['open']?.trend ?? '0%',
            stats['open']?.percent ?? '0%',
            _statusTextColor('PENDING', isDark),
            _statusFillColor('PENDING', isDark),
            _statusBorderColor('PENDING', isDark),
            isDark,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            l10n.statusFinished, // Used for "Completed"
            (stats['completed']?.count ?? 0).toString(),
            stats['completed']?.trend ?? '0%',
            stats['completed']?.percent ?? '0%',
            _statusTextColor('COMPLETED', isDark),
            _statusFillColor('COMPLETED', isDark),
            _statusBorderColor('COMPLETED', isDark),
            isDark,
            textColor,
            textSecondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            l10n.statusOverdue,
            (stats['overdue']?.count ?? 0).toString(),
            stats['overdue']?.trend ?? '0%',
            stats['overdue']?.percent ?? '0%',
            _statusTextColor('OVERDUE', isDark),
            _statusFillColor('OVERDUE', isDark),
            _statusBorderColor('OVERDUE', isDark),
            isDark,
            textColor,
            textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String trend,
    String percent,
    Color trendColor,
    Color fillColor,
    Color borderColor,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final isDown = trend.startsWith('-');
    final isUp = trend.startsWith('+') || (!isDown && trend != '0%');
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: trendColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: trendColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headline2.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    if (isUp)
                      Icon(
                        Icons.arrow_drop_up,
                        color: trendColor,
                        size: 18,
                      )
                    else if (isDown)
                      Icon(
                        Icons.arrow_drop_down,
                        color: trendColor,
                        size: 18,
                      ),
                    Text(
                      trend,
                      style: AppTypography.captionSmall.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$percent do total',
              style: AppTypography.captionSmall.copyWith(
                color: textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: AppTypography.subtitle1.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  Icons.precision_manufacturing_outlined,
                  l10n.equipmentLabel, // Changed from createEquipment
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.people_outline,
                  l10n.clients,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientsListScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  Icons.rule_outlined,
                  l10n.checklistTemplates,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChecklistTemplatesScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  Icons.engineering_outlined,
                  l10n.techniciansLabel,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TechniciansScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // New Service Order Button (Full Width)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateServiceOrderScreen(),
                  ),
                ).then((result) {
                  if (result == true) _loadOrders();
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.newOrder,
                      style: AppTypography.button.copyWith(color: Colors.white),
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

  Widget _buildQuickActionCard(
    IconData icon,
    String label,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTypography.bodyTextSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l10n,
    List<Order> orders,
    int? currentUserId,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentOrders,
                style: AppTypography.subtitle1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.viewAll,
                  style: AppTypography.bodyTextSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingOrders)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            )
          else if (_ordersError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.recentOrdersError,
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
            )
          else if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.noRecentOrders,
                style: AppTypography.bodyTextSmall.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCardFromOrder(
                  order,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textColor,
                  textSecondaryColor,
                  l10n,
                  currentUserId,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCardFromOrder(
    Order order,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textSecondaryColor,
    AppLocalizations l10n,
    int? currentUserId,
  ) {
    final badge = _priorityBadge(order.priority, isDark, l10n);
    final time = _timeAgo(order.dataCriacao);
    final location = _orderLocation(order, l10n.locationNotSpecified);
    final roleLabel = _roleLabelForOrder(order, currentUserId, l10n);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(
            color: _statusBorderColor(order.status, isDark),
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color:
                        _statusTextColor(order.status, isDark).withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SO-${order.id}',
                        style: AppTypography.overline.copyWith(
                          color: textSecondaryColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.equipamento.nome,
                        style: AppTypography.bodyTextSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (roleLabel != null) ...[
                        const SizedBox(height: 6),
                        _roleChip(roleLabel, isDark),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? badge.bg.withOpacity(0.2) : badge.bg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge.text.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      fontSize: 10,
                      color: isDark ? badge.color.withOpacity(0.8) : badge.color,
                      letterSpacing: 0.5,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: AppTypography.captionSmall.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: AppTypography.captionSmall.copyWith(
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _roleChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
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

  Map<String, _StatusStats> _buildStats() {
    final now = DateTime.now();
    final currentStart = now.subtract(const Duration(days: 7));
    final previousStart = now.subtract(const Duration(days: 14));

    int open = 0;
    int completed = 0;
    int overdue = 0;
    int openPrev = 0;
    int completedPrev = 0;
    int overduePrev = 0;

    for (final order in _orders) {
      final createdAt =
          order.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(0);
      final isCurrent = createdAt.isAfter(currentStart);
      final isPrevious =
          createdAt.isAfter(previousStart) && createdAt.isBefore(currentStart);
      if (!isCurrent && !isPrevious) continue;

      switch (order.status) {
        case 'FINALIZADA':
          if (isCurrent) {
            completed++;
          } else if (isPrevious) {
            completedPrev++;
          }
          break;
        case 'ATRASADA':
          if (isCurrent) {
            overdue++;
          } else if (isPrevious) {
            overduePrev++;
          }
          break;
        default:
          if (isCurrent) {
            open++;
          } else if (isPrevious) {
            openPrev++;
          }
      }
    }

    final totalCurrent = open + completed + overdue;

    return {
      'open': _StatusStats(
        open,
        _trendString(open, openPrev),
        _percentString(open, totalCurrent),
      ),
      'completed': _StatusStats(
        completed,
        _trendString(completed, completedPrev),
        _percentString(completed, totalCurrent),
      ),
      'overdue': _StatusStats(
        overdue,
        _trendString(overdue, overduePrev),
        _percentString(overdue, totalCurrent),
      ),
    };
  }

  String _trendString(int current, int previous) {
    if (previous == 0) {
      if (current == 0) return '0%';
      return '+100%';
    }
    final change = ((current - previous) / previous) * 100;
    final rounded = change.round();
    final sign = rounded > 0 ? '+' : '';
    return '$sign$rounded%';
  }

  String _percentString(int count, int total) {
    if (total == 0) return '0%';
    final percent = ((count / total) * 100).round();
    return '$percent%';
  }

  Color _statusTextColor(String status, bool isDark) {
    switch (status) {
      case 'FINALIZADA':
      case 'COMPLETED':
        return isDark
            ? AppColors.statusCompletedTextDark
            : AppColors.statusCompletedText;
      case 'ATRASADA':
      case 'OVERDUE':
      case 'CANCELADA':
        return isDark
            ? AppColors.statusFailedTextDark
            : AppColors.statusFailedText;
      case 'EM_ANDAMENTO':
      case 'IN_PROGRESS':
        return isDark
            ? AppColors.statusInProgressTextDark
            : AppColors.statusInProgressText;
      default:
        return isDark
            ? AppColors.statusPendingTextDark
            : AppColors.statusPendingText;
    }
  }

  Color _statusFillColor(String status, bool isDark) {
    switch (status) {
      case 'FINALIZADA':
      case 'COMPLETED':
        return isDark
            ? AppColors.statusCompletedBgDark
            : AppColors.statusCompletedBg;
      case 'ATRASADA':
      case 'OVERDUE':
      case 'CANCELADA':
        return isDark
            ? AppColors.statusFailedBgDark
            : AppColors.statusFailedBg;
      case 'EM_ANDAMENTO':
      case 'IN_PROGRESS':
        return isDark
            ? AppColors.statusInProgressBgDark
            : AppColors.statusInProgressBg;
      default:
        return isDark
            ? AppColors.statusPendingBgDark
            : AppColors.statusPendingBg;
    }
  }

  Color _statusBorderColor(String status, bool isDark) {
    switch (status) {
      case 'FINALIZADA':
      case 'COMPLETED':
        return isDark
            ? AppColors.statusCompletedBorderDark
            : AppColors.statusCompletedText.withOpacity(0.2);
      case 'ATRASADA':
      case 'OVERDUE':
      case 'CANCELADA':
        return isDark
            ? AppColors.statusFailedBorderDark
            : AppColors.statusFailedText.withOpacity(0.2);
      case 'EM_ANDAMENTO':
      case 'IN_PROGRESS':
        return isDark
            ? AppColors.statusInProgressBorderDark
            : AppColors.statusInProgressText.withOpacity(0.2);
      default:
        return isDark
            ? AppColors.statusPendingBorderDark
            : AppColors.statusPendingText.withOpacity(0.2);
    }
  }

  List<Order> _recentOrders() {
    final list = List<Order>.from(_orders);
    list.sort((a, b) {
      final aDate = a.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return list.take(3).toList();
  }

  _BadgeData _priorityBadge(
    String priority,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final raw = priority.toLowerCase();
    if (raw.contains('alta') || raw.contains('high')) {
      return _BadgeData(
        text: l10n.priorityHigh,
        bg: AppColors.warningLight.withOpacity(0.3),
        color: Colors.orange[900]!,
      );
    }
    if (raw.contains('media') || raw.contains('medium')) {
      return _BadgeData(
        text: l10n.priorityMedium,
        bg: AppColors.infoLight.withOpacity(0.3),
        color: AppColors.infoDark,
      );
    }
    return _BadgeData(
      text: l10n.priorityLow,
      bg: AppColors.slate100,
      color: AppColors.slate600,
    );
  }

  String _orderLocation(Order order, String locationNotSpecified) {
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
    ].where((e) => e != null && e.isNotEmpty).map((e) => e!).toList();
    if (parts.isEmpty) return locationNotSpecified;
    return parts.join(' • ');
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return 'recente';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.dashboard_outlined,
            l10n.home,
            _selectedIndex == 0,
            isDark,
            0,
          ),
          _buildNavItem(
            Icons.assignment_turned_in_outlined,
            l10n.ordersTab,
            _selectedIndex == 1,
            isDark,
            1,
          ),
          _buildNavItem(
            Icons.inventory_2_outlined,
            l10n.inventoryTab,
            _selectedIndex == 2,
            isDark,
            2,
          ),
          _buildNavItem(
            Icons.notifications_none,
            l10n.notificationsTab,
            _selectedIndex == 3,
            isDark,
            3,
          ),
          _buildNavItem(
            Icons.person_outline,
            l10n.profileTab,
            _selectedIndex == 4,
            isDark,
            4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    bool isDark,
    int index,
  ) {
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.slate500 : AppColors.slate400);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index == 1) {
            _ordersKey.currentState?.refreshOrders();
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String text;
  final Color bg;
  final Color color;

  _BadgeData({required this.text, required this.bg, required this.color});
}

class _StatusStats {
  final int count;
  final String trend;
  final String percent;

  _StatusStats(this.count, this.trend, this.percent);
}
