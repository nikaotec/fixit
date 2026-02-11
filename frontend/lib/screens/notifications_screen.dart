import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/firestore_notification_service.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDarkTheme
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como lidas',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreNotificationService.streamNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar notificações',
                style: AppTypography.bodyText.copyWith(
                  color: isDark ? AppColors.slate300 : AppColors.slate600,
                ),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: isDark ? AppColors.slate600 : AppColors.slate400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma notificação',
                    style: AppTypography.bodyText.copyWith(
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['read'] == true;
              final timestamp = notification['createdAt'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final notificationId = notification['id'];

              return Dismissible(
                key: Key(notificationId),
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteNotification(notificationId),
                child: Container(
                  decoration: BoxDecoration(
                    color: isRead
                        ? (isDark ? AppColors.surfaceDarkTheme : Colors.white)
                        : (isDark
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDefaultDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? (isDark ? AppColors.slate700 : AppColors.slate200)
                          : AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.notifications,
                        color: isRead
                            ? (isDark ? AppColors.slate400 : AppColors.slate500)
                            : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      notification['title'] ?? 'Sem título',
                      style: AppTypography.bodyText.copyWith(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification['body'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              notification['body'],
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.slate300
                                    : AppColors.slate600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('dd/MM HH:mm').format(date),
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark
                                  ? AppColors.slate500
                                  : AppColors.slate400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _markAsRead(notificationId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    await FirestoreNotificationService.markAsRead(notificationId);
  }

  Future<void> _markAllAsRead() async {
    await FirestoreNotificationService.markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as notificações marcadas como lidas'),
        ),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
