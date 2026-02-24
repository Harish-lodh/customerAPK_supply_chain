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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      final mockList = TransactionList.mock(page: _currentPage);
      
      if (refresh) {
        _transactions = mockList.transactions;
      } else {
        _transactions.addAll(mockList.transactions);
      }
      
      _hasMore = mockList.hasMore;
      _currentPage++;
      _state = TransactionsState.loaded;
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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock receipt
      _receipt = TransactionReceipt(
        transactionId: transactionId,
        loanNumber: 'SCF/2024/001',
        transactionType: 'REPAYMENT',
        amount: 250000,
        transactionDate: DateTime.now(),
        status: 'SUCCESS',
        utrNumber: 'UTR${DateTime.now().millisecondsSinceEpoch}',
        paymentMode: 'NEFT',
        bankName: 'HDFC Bank',
        accountNumber: '50200012345678',
        remarks: 'EMI Payment - January 2024',
        companyName: 'ABC Traders Pvt Ltd',
        companyGst: '29AABCU9600R1ZN',
      );
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
