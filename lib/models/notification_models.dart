class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
    this.data,
  });
  
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      actionUrl: json['action_url'],
      data: json['data'],
    );
  }
  
  // Mock data for demo
  factory AppNotification.mock(int index) {
    final types = ['LOAN_APPROVED', 'EMI_DUE', 'OVERDUE', 'INVOICE_STATUS', 'GENERAL'];
    final titles = [
      'Loan Approved',
      'EMI Due Reminder',
      'Overdue Alert',
      'Invoice Status Update',
      'Important Update',
    ];
    final messages = [
      'Your loan application SCF/2024/001 has been approved.',
      'Your EMI of ₹2,50,000 is due on 25th February 2024.',
      'Your loan SCF/2024/001 has an overdue amount of ₹50,000.',
      'Your invoice request INV/2024/001 has been processed.',
      'Please update your contact details for better service.',
    ];
    
    return AppNotification(
      id: 'NOTIF$index',
      title: titles[index % 5],
      message: messages[index % 5],
      type: types[index % 5],
      createdAt: DateTime.now().subtract(Duration(hours: index * 6)),
      isRead: index > 2,
      actionUrl: null,
      data: null,
    );
  }
  
  String get typeDisplay {
    switch (type) {
      case 'LOAN_APPROVED':
        return 'Loan Approved';
      case 'EMI_DUE':
        return 'EMI Due';
      case 'OVERDUE':
        return 'Overdue';
      case 'INVOICE_STATUS':
        return 'Invoice';
      case 'GENERAL':
        return 'General';
      default:
        return type;
    }
  }
}

class NotificationList {
  final List<AppNotification> notifications;
  final int unreadCount;
  final int totalCount;
  
  NotificationList({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
  });
  
  factory NotificationList.fromJson(Map<String, dynamic> json) {
    return NotificationList(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => AppNotification.fromJson(e))
          .toList() ?? [],
      unreadCount: json['unread_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
  
  // Mock data for demo
  factory NotificationList.mock() {
    List<AppNotification> notifications = [];
    for (int i = 0; i < 10; i++) {
      notifications.add(AppNotification.mock(i));
    }
    
    return NotificationList(
      notifications: notifications,
      unreadCount: 3,
      totalCount: 10,
    );
  }
}
