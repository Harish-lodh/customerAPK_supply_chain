import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/drawdown_models.dart';

enum DrawdownState {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class DrawdownProvider extends ChangeNotifier {
  final ApiService apiService;
  
  DrawdownState _state = DrawdownState.initial;
  List<DrawdownRequest> _drawdownRequests = [];
  List<Dealer> _dealers = [];
  List<Invoice> _invoices = [];
  DrawdownCalculation? _calculation;
  String? _errorMessage;
  String? _successMessage;
  
  DrawdownProvider({required this.apiService});
  
  // Getters
  DrawdownState get state => _state;
  List<DrawdownRequest> get drawdownRequests => _drawdownRequests;
  List<Dealer> get dealers => _dealers;
  List<Invoice> get invoices => _invoices;
  DrawdownCalculation? get calculation => _calculation;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  // Load Drawdown Requests
  Future<void> loadDrawdownRequests() async {
    _state = DrawdownState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _drawdownRequests = [
        DrawdownRequest.mock(1),
        DrawdownRequest.mock(2),
        DrawdownRequest.mock(3),
        DrawdownRequest.mock(4),
      ];
      _state = DrawdownState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load drawdown requests.';
      _state = DrawdownState.error;
    }
    notifyListeners();
  }
  
  // Load Dealers
  Future<void> loadDealers() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data
      _dealers = List.generate(5, (index) => Dealer.mock(index + 1));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dealers.';
      notifyListeners();
    }
  }
  
  // Load Invoices
  Future<void> loadInvoices() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data
      _invoices = List.generate(10, (index) => Invoice.mock(index + 1));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load invoices.';
      notifyListeners();
    }
  }
  
  // Calculate Processing Fee
  void calculateProcessingFee(double amount) {
    if (amount > 0) {
      _calculation = DrawdownCalculation.calculate(amount);
    } else {
      _calculation = null;
    }
    notifyListeners();
  }
  
  // Submit Drawdown Request
  Future<bool> submitDrawdownRequest({
    required String invoiceId,
    required String dealerId,
    required double amount,
  }) async {
    _state = DrawdownState.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock success
      _successMessage = 'Drawdown request submitted successfully!';
      _state = DrawdownState.success;
      
      // Reload requests
      await loadDrawdownRequests();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit drawdown request.';
      _state = DrawdownState.error;
      return false;
    }
  }
  
  // Clear Calculation
  void clearCalculation() {
    _calculation = null;
    notifyListeners();
  }
  
  // Clear Messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  // Reset State
  void resetState() {
    _state = DrawdownState.initial;
    _calculation = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  // Refresh
  Future<void> refresh() async {
    await loadDrawdownRequests();
  }
}
