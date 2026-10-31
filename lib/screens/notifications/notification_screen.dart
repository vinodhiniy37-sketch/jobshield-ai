import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/empty_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.securityAlert:
        return AppColors.danger;
      case NotificationType.scanCompleted:
        return AppColors.success;
      case NotificationType.systemUpdate:
        return AppColors.info;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.securityAlert:
        return Icons.gpp_bad_rounded;
      case NotificationType.scanCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.systemUpdate:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);
    final notifications = service.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat & Alert Center'),
        actions: [
          if (service.unreadNotificationsCount > 0)
            TextButton(
              onPressed: () {
                service.markAllNotificationsAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All alerts marked as read.')),
                );
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const EmptyState(
                title: 'No Notifications',
                description: 'Your alert feed is clean. We will notify you here when new job scam trends are found or scans complete.',
                icon: Icons.notifications_off_outlined,
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final AppNotification item = notifications[index];
                  final iconColor = _getIconColor(item.type);
                  final isUnread = !item.isRead;
                  final timeString = DateFormat('MMM d, h:mm a').format(item.timestamp);

                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                    ),
                    onDismissed: (direction) {
                      service.deleteNotification(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification removed.')),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? AppColors.primary.withOpacity(isDark ? 0.08 : 0.05)
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnread
                              ? AppColors.primary.withOpacity(0.2)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(item.type),
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              item.message,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextSecondary.withOpacity(0.4) : AppColors.lightTextSecondary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (isUnread) {
                            service.markNotificationAsRead(item.id);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
