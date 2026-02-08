import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/order_event_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _error;
  List<_NotificationItem> _items = [];
  String? _lastToken;
  WebSocketChannel? _ordersChannel;
  StreamSubscription? _ordersSub;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token != null && token != _lastToken) {
      _lastToken = token;
      _connectRealtime(token);
      _loadNotifications();
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
          _loadNotifications();
        }
      } catch (_) {
        _loadNotifications();
      }
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token == null) return;
      final list = await NotificationService.getAll(token: token);
      setState(() => _items = _buildFromApi(list));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Erro ao carregar notificações',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma notificação',
          style: AppTypography.bodyText.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkTheme : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark ? AppColors.borderDefaultDark : AppColors.borderLight,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyText.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: AppTypography.caption.copyWith(
                        color:
                            isDark ? AppColors.slate300 : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.time,
                style: AppTypography.captionSmall.copyWith(
                  color: isDark ? AppColors.slate400 : AppColors.slate500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_NotificationItem> _buildFromApi(List<Map<String, dynamic>> list) {
    return list.map((item) {
      final type = (item['type'] ?? '').toString().toUpperCase();
      final title = item['title']?.toString() ?? 'Notification';
      final subtitle = item['subtitle']?.toString() ?? '';
      final createdAt = item['createdAt']?.toString();
      final time = _timeAgo(createdAt != null ? DateTime.tryParse(createdAt) : null);
      final meta = _mapType(type);
      return _NotificationItem(
        icon: meta.icon,
        color: meta.color,
        title: title,
        subtitle: subtitle,
        time: time,
      );
    }).toList();
  }

  _NotificationMeta _mapType(String type) {
    switch (type) {
      case 'OVERDUE':
        return _NotificationMeta(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
        );
      case 'COMPLETED':
        return _NotificationMeta(
          icon: Icons.check_circle,
          color: AppColors.success,
        );
      case 'IN_PROGRESS':
        return _NotificationMeta(
          icon: Icons.timelapse,
          color: AppColors.info,
        );
      default:
        return _NotificationMeta(
          icon: Icons.info_outline,
          color: AppColors.info,
        );
    }
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return 'recent';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _NotificationMeta {
  final IconData icon;
  final Color color;

  _NotificationMeta({required this.icon, required this.color});
}
