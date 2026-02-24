import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/notification_models.dart';

enum NotificationsState {
  initial,
  loading,
  loaded,
  error,
}

class NotificationsProvider extends ChangeNotifier {
  final ApiService apiService;
  
  NotificationsState _state = NotificationsState.initial;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;
  
  NotificationsProvider({required this.apiService});
  
  // Getters
  NotificationsState get state => _state;
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;
  
  // Load Notifications
  Future<void> loadNotifications() async {
    _state = NotificationsState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      final mockList = NotificationList.mock();
      _notifications = mockList.notifications;
      _unreadCount = mockList.unreadCount;
      _state = NotificationsState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load notifications.';
      _state = NotificationsState.error;
    }
    notifyListeners();
  }
  
  // Mark as Read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Update local state
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          actionUrl: _notifications[index].actionUrl,
          data: _notifications[index].data,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read.';
      notifyListeners();
    }
  }
  
  // Mark All as Read
  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
        actionUrl: n.actionUrl,
        data: n.data,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark all as read.';
      notifyListeners();
    }
  }
  
  // Refresh Notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}
