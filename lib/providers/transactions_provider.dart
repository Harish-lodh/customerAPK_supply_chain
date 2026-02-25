import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/transaction_models.dart';

enum TransactionsState {
  initial,
  loading,
  loaded,
  error,
}

class TransactionsProvider extends ChangeNotifier {
  final ApiService apiService;
  
  TransactionsState _state = TransactionsState.initial;
  List<Transaction> _transactions = [];
  TransactionReceipt? _receipt;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  
  TransactionsProvider({required this.apiService});
  
  // Getters
  TransactionsState get state => _state;
  List<Transaction> get transactions => _transactions;
  TransactionReceipt? get receipt => _receipt;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  
  // Load Transactions
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _transactions = [];
    }
    
    _state = TransactionsState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getTransactions(_currentPage, 20);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['transactions'] ?? response.data;
        final newTransactions = data.map((json) => Transaction.fromJson(json)).toList();
        
        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }
        
        // Check if there are more pages
        _hasMore = newTransactions.length >= 20;
        _currentPage++;
        _state = TransactionsState.loaded;
      } else {
        _errorMessage = 'Failed to load transactions. Please try again.';
        _state = TransactionsState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load transactions. Please try again.';
      _state = TransactionsState.error;
    }
    notifyListeners();
  }
  
  // Load More Transactions
  Future<void> loadMore() async {
    if (!_hasMore || _state == TransactionsState.loading) return;
    await loadTransactions();
  }
  
  // Get Transaction Receipt
  Future<void> getTransactionReceipt(String transactionId) async {
    try {
      final response = await apiService.getTransactionReceipt(transactionId);
      
      if (response.statusCode == 200 && response.data != null) {
        _receipt = TransactionReceipt.fromJson(response.data);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load receipt.';
      notifyListeners();
    }
  }
  
  // Clear Receipt
  void clearReceipt() {
    _receipt = null;
    notifyListeners();
  }
  
  // Refresh Transactions
  Future<void> refresh() async {
    await loadTransactions(refresh: true);
  }
}
