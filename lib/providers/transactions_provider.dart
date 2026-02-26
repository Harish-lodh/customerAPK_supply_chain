import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/transaction_models.dart';
import '../models/loan_models.dart';
import '../core/services/session_service.dart';

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
  List<CollectionTransaction> _collectionTransactions = [];
  TransactionReceipt? _receipt;
  TransactionDetail? _transactionDetail;
  bool _isLoadingDetail = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  
  // LAN selection
  List<Loan> _availableLoans = [];
  String? _selectedLan;
  final bool isLoadingLoans = false;
  
  // Lender type selection
  List<String> _lenderTypes = [];
  String? _selectedLenderType;
  bool _isLoadingLenderTypes = false;
  
  TransactionsProvider({required this.apiService});
  
  // Getters
  TransactionsState get state => _state;
  List<Transaction> get transactions => _transactions;
  List<CollectionTransaction> get collectionTransactions => _collectionTransactions;
  TransactionReceipt? get receipt => _receipt;
  TransactionDetail? get transactionDetail => _transactionDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  
  // LAN getters
  List<Loan> get availableLoans => _availableLoans;
  String? get selectedLan => _selectedLan;
  
  // Lender type getters
  List<String> get lenderTypes => _lenderTypes;
  String? get selectedLenderType => _selectedLenderType;
  bool get isLoadingLenderTypes => _isLoadingLenderTypes;
  
  // Get list of LANs from available loans
  List<String> get availableLans {
    return _availableLoans.map((loan) => loan.loanNumber).toList();
  }
  
  // Initialize and load available LANs
  Future<void> initializeLans(List<Loan> loans) async {
    _availableLoans = loans;
    
    // Get list of loan numbers from new loans
    final availableLoanNumbers = _availableLoans.map((loan) => loan.loanNumber).toList();
    
    // Reset selected LAN if it no longer exists in the new loans list
    if (_selectedLan != null && !availableLoanNumbers.contains(_selectedLan)) {
      _selectedLan = null;
    }
    
    // If there's a selected lender type, use it as LAN (API expects lender type as lan)
    if (_selectedLenderType != null) {
      _selectedLan = _selectedLenderType;
    } else if (_selectedLan == null) {
      // If there's a partnerLanId from session, use it; otherwise use first loan's LAN
      final partnerLanId = await SessionService.getPartnerLanId();
      if (partnerLanId != null && partnerLanId.isNotEmpty && availableLoanNumbers.contains(partnerLanId)) {
        _selectedLan = partnerLanId;
      } else if (_availableLoans.isNotEmpty) {
        _selectedLan = _availableLoans.first.loanNumber;
      }
    }
    
    notifyListeners();
    
    // Load transactions for selected LAN
    if (_selectedLan != null) {
      await loadTransactionsByLan();
    }
  }
  
  // Load lender types from API
  Future<void> loadLenderTypes() async {
    _isLoadingLenderTypes = true;
    notifyListeners();
    
    try {
      final response = await apiService.getLenderTypes();
      
      if (response.statusCode == 200 && response.data != null) {
        // Handle response format: { "success": true, "data": ["Fintree", "Kite", "Muthoot"] }
        if (response.data['success'] == true && response.data['data'] != null) {
          _lenderTypes = List<String>.from(response.data['data']);
        }
        
        // Reset selected lender type if it no longer exists in the new lender types list
        if (_selectedLenderType != null && !_lenderTypes.contains(_selectedLenderType)) {
          _selectedLenderType = null;
        }
        
        // Set default selected lender type if not set
        if (_selectedLenderType == null && _lenderTypes.isNotEmpty) {
          _selectedLenderType = _lenderTypes.first;
        }
      }
    } catch (e) {
      // Silently fail - lender types are optional
      debugPrint('Failed to load lender types: $e');
    }
    
    _isLoadingLenderTypes = false;
    notifyListeners();
  }
  
  // Set selected lender type
  Future<void> selectLenderType(String? lenderType, {List<Loan>? availableLoans}) async {
    if (_selectedLenderType != lenderType) {
      _selectedLenderType = lenderType;
      // Set LAN to the lender type value (API expects lender type as lan parameter)
      _selectedLan = lenderType;
      _collectionTransactions = [];
      notifyListeners();
      
      // Load transactions for the new lender
      await loadTransactionsByLan();
    }
  }
  
  // Set selected LAN and reload transactions
  Future<void> selectLan(String lan) async {
    if (_selectedLan != lan) {
      _selectedLan = lan;
      _collectionTransactions = [];
      notifyListeners();
      await loadTransactionsByLan();
    }
  }
  
  // Load Transactions by LAN
  Future<void> loadTransactionsByLan({bool refresh = false}) async {
    if (_selectedLan == null) {
      _errorMessage = 'Please select a LAN';
      _state = TransactionsState.error;
      notifyListeners();
      return;
    }
    
    if (refresh) {
      _currentPage = 1;
      _collectionTransactions = [];
    }
    
    _state = TransactionsState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getTransactionsByLan(_selectedLan!);
      
      if (response.statusCode == 200 && response.data != null) {
        // Handle new response format: { "success": true, "data": [...] }
        if (response.data['success'] == true && response.data['data'] != null) {
          final List<dynamic> data = response.data['data'];
          final newTransactions = data.map((json) => CollectionTransaction.fromJson(json)).toList();
          
          if (refresh) {
            _collectionTransactions = newTransactions;
          } else {
            _collectionTransactions.addAll(newTransactions);
          }
        } else {
          // Fallback to old format
          final List<dynamic> data = response.data['transactions'] ?? response.data;
          final newTransactions = data.map((json) => CollectionTransaction.fromJson(json)).toList();
          
          if (refresh) {
            _collectionTransactions = newTransactions;
          } else {
            _collectionTransactions.addAll(newTransactions);
          }
        }
        
        _hasMore = _collectionTransactions.length >= 20;
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
  
  // Load Transactions (legacy method - paginated)
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
    
    // If we have a selected LAN, load more by LAN
    if (_selectedLan != null) {
      await loadTransactionsByLan();
    } else {
      await loadTransactions();
    }
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
  
  // Get Transaction Detail with Allocation
  Future<void> getTransactionDetail(String lan, String utr) async {
    _isLoadingDetail = true;
    _transactionDetail = null;
    notifyListeners();
    
    try {
      final response = await apiService.getTransactionDetail(lan, utr);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          _transactionDetail = TransactionDetail.fromJson(response.data['data']);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load transaction details.';
    }
    
    _isLoadingDetail = false;
    notifyListeners();
  }
  
  // Clear Transaction Detail
  void clearTransactionDetail() {
    _transactionDetail = null;
    notifyListeners();
  }
  
  // Refresh Transactions
  Future<void> refresh() async {
    if (_selectedLan != null) {
      await loadTransactionsByLan(refresh: true);
    } else {
      await loadTransactions(refresh: true);
    }
  }
  
  // Clear all data
  void clear() {
    _transactions = [];
    _collectionTransactions = [];
    _receipt = null;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _selectedLan = null;
    _selectedLenderType = null;
    _lenderTypes = [];
    _state = TransactionsState.initial;
    notifyListeners();
  }
}
