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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _loans = [
        Loan.mock(1),
        Loan.mock(2),
        Loan.mock(3),
      ];
      _state = LoansState.loaded;
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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find loan and get schedule
      final loan = _loans.firstWhere((l) => l.id == loanId);
      _selectedLoan = loan;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load EMI schedule.';
      notifyListeners();
    }
  }
  
  // Load Loan Statement
  Future<void> loadLoanStatement(String loanId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock statement data
      _loanStatement = LoanStatement(
        loanId: loanId,
        loanNumber: 'SCF/2024/001',
        fromDate: DateTime.now().subtract(const Duration(days: 90)),
        toDate: DateTime.now(),
        openingBalance: 3500000,
        closingBalance: 2800000,
        totalDisbursement: 500000,
        totalRepayment: 750000,
        entries: [],
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load statement.';
      notifyListeners();
    }
  }
  
  // Get Foreclosure Preview
  Future<void> getForeclosurePreview(String loanId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock preview data
      _foreclosurePreview = ForeclosurePreview(
        loanId: loanId,
        outstandingPrincipal: 2800000,
        interestOutstanding: 25000,
        foreclosureCharges: 28000,
        gstAmount: 5040,
        totalForeclosureAmount: 2875040,
      );
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
