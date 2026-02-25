import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/loan_models.dart';

enum LoansState {
  initial,
  loading,
  loaded,
  error,
}

class LoansProvider extends ChangeNotifier {
  final ApiService apiService;
  
  LoansState _state = LoansState.initial;
  List<Loan> _loans = [];
  Loan? _selectedLoan;
  LoanStatement? _loanStatement;
  ForeclosurePreview? _foreclosurePreview;
  String? _errorMessage;
  
  LoansProvider({required this.apiService});
  
  // Getters
  LoansState get state => _state;
  List<Loan> get loans => _loans;
  Loan? get selectedLoan => _selectedLoan;
  LoanStatement? get loanStatement => _loanStatement;
  ForeclosurePreview? get foreclosurePreview => _foreclosurePreview;
  String? get errorMessage => _errorMessage;
  
  // Load Loans
  Future<void> loadLoans() async {
    _state = LoansState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getLoans();
      
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> data = responseData['data'] ?? [];
        _loans = data.map((json) => Loan.fromJson(json)).toList();
        _state = LoansState.loaded;
      } else {
        _errorMessage = 'Failed to load loans. Please try again.';
        _state = LoansState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load loans. Please try again.';
      _state = LoansState.error;
    }
    notifyListeners();
  }
  
  // Select Loan
  void selectLoan(Loan loan) {
    _selectedLoan = loan;
    notifyListeners();
  }
  
  // Clear Selected Loan
  void clearSelectedLoan() {
    _selectedLoan = null;
    _loanStatement = null;
    _foreclosurePreview = null;
    notifyListeners();
  }
  
  // Load Loan EMI Schedule
  Future<void> loadEmiSchedule(String loanId) async {
    try {
      // Find the loan by ID and get its LAN (loanNumber)
      final loan = _loans.firstWhere((l) => l.id == loanId);
      final lan = loan.loanNumber; // This is the LAN from the loans API
      
      final response = await apiService.getLoanSchedule(lan);
      
      if (response.statusCode == 200 && response.data != null) {
        _selectedLoan = loan;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load EMI schedule.';
      notifyListeners();
    }
  }
  
  // Load Loan Statement
  Future<void> loadLoanStatement(String loanId, String fromDate, String toDate) async {
    try {
      final response = await apiService.getLoanStatement(loanId, fromDate, toDate);
      
      if (response.statusCode == 200 && response.data != null) {
        _loanStatement = LoanStatement.fromJson(response.data);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load statement.';
      notifyListeners();
    }
  }
  
  // Get Foreclosure Preview
  Future<void> getForeclosurePreview(String loanId) async {
    try {
      final response = await apiService.getForeclosurePreview(loanId);
      
      if (response.statusCode == 200 && response.data != null) {
        _foreclosurePreview = ForeclosurePreview.fromJson(response.data);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load foreclosure preview.';
      notifyListeners();
    }
  }
  
  // Refresh Loans
  Future<void> refresh() async {
    await loadLoans();
  }
}
