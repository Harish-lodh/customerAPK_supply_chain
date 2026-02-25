import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/dashboard_models.dart';

enum DashboardState {
  initial,
  loading,
  loaded,
  error,
}

class DashboardProvider extends ChangeNotifier {
  final ApiService apiService;
  
  DashboardState _state = DashboardState.initial;
  Dashboard? _dashboard;
  String? _errorMessage;
  
  DashboardProvider({required this.apiService});
  
  // Getters
  DashboardState get state => _state;
  Dashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  
  // Load Dashboard Data
  Future<void> loadDashboard() async {
    _state = DashboardState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getDashboard();
      
      if (response.statusCode == 200 && response.data != null) {
        _dashboard = Dashboard.fromJson(response.data);
        _state = DashboardState.loaded;
      } else {
        _errorMessage = 'Failed to load dashboard';
        _state = DashboardState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Please try again.';
      _state = DashboardState.error;
    }
    notifyListeners();
  }
  
  // Refresh Dashboard
  Future<void> refresh() async {
    await loadDashboard();
  }
  
  // Get limit utilization data
  LimitUtilization? get limitUtilization {
    if (_dashboard == null) return null;
    return LimitUtilization.fromDashboard(_dashboard!);
  }
}
