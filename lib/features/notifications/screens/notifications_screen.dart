import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notifications_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationsProvider>(context, listen: false).markAllAsRead();
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          if (provider.state == NotificationsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notification.isRead ? null : AppColors.primaryBlue.withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.notifications, color: AppColors.primaryBlue),
                    ),
                    title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(dateFormat.format(notification.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    onTap: () => provider.markAsRead(notification.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
