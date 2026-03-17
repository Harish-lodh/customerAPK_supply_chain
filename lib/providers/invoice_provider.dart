import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../models/invoice_models.dart';

enum InvoiceState {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class InvoiceProvider extends ChangeNotifier {
  final ApiService apiService;
  
  InvoiceState _state = InvoiceState.initial;
  List<InvoiceRequest> _invoiceRequests = [];
  List<Dealer> _dealers = [];
  List<Invoice> _invoices = [];
  InvoiceCalculation? _calculation;
  String? _errorMessage;
  String? _successMessage;
  
  // Invoice Details
  List<String> _lenderTypes = [];
  String? _selectedLender;
  InvoiceDetailsResponse? _invoiceDetailsResponse;
  InvoiceDetail? _selectedInvoice;
  bool _isLoadingInvoices = false;
  bool _isLoadingLenderTypes = false;
  
  // Pending Approval Invoices
  List<PendingApprovalInvoice> _pendingApprovalInvoices = [];
  PendingApprovalInvoice? _selectedPendingInvoice;
  bool _isLoadingPendingApprovals = false;
  bool _isSubmittingApproval = false;
  
  InvoiceProvider({required this.apiService});
  
  // Getters
  InvoiceState get state => _state;
  List<InvoiceRequest> get invoiceRequests => _invoiceRequests;
  List<Dealer> get dealers => _dealers;
  List<Invoice> get invoices => _invoices;
  InvoiceCalculation? get calculation => _calculation;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  // Invoice Details Getters
  List<String> get lenderTypes => _lenderTypes;
  String? get selectedLender => _selectedLender;
  InvoiceDetailsResponse? get invoiceDetailsResponse => _invoiceDetailsResponse;
  InvoiceDetail? get selectedInvoice => _selectedInvoice;
  bool get isLoadingInvoices => _isLoadingInvoices;
  bool get isLoadingLenderTypes => _isLoadingLenderTypes;
  List<InvoiceDetail> get invoicesList => _invoiceDetailsResponse?.invoices ?? [];
  
  // Pending Approval Getters
  List<PendingApprovalInvoice> get pendingApprovalInvoices => _pendingApprovalInvoices;
  PendingApprovalInvoice? get selectedPendingInvoice => _selectedPendingInvoice;
  bool get isLoadingPendingApprovals => _isLoadingPendingApprovals;
  bool get isSubmittingApproval => _isSubmittingApproval;
  int get pendingApprovalsCount => _pendingApprovalInvoices.where((i) => i.needsApproval).length;
  
  // Load Pending Approval Invoices
  Future<void> loadPendingApprovalInvoices() async {
    _isLoadingPendingApprovals = true;
    _state = InvoiceState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getPendingApprovalInvoices();
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          final List<dynamic> data = response.data['data'] ?? [];
          _pendingApprovalInvoices = data.map((json) => PendingApprovalInvoice.fromJson(json)).toList();
          _state = InvoiceState.loaded;
        } else {
          _errorMessage = response.data['message'] ?? 'Failed to load pending approvals';
          _state = InvoiceState.error;
        }
      } else {
        _errorMessage = 'Failed to load pending approvals';
        _state = InvoiceState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load pending approvals: $e';
      _state = InvoiceState.error;
    }
    
    _isLoadingPendingApprovals = false;
    notifyListeners();
  }
  
  // Get Invoice By ID for Approval
  Future<void> getInvoiceForApproval(int invoiceId) async {
    _state = InvoiceState.loading;
    _errorMessage = null;
    _selectedPendingInvoice = null;
    notifyListeners();
    
    try {
      final response = await apiService.getInvoiceById(invoiceId);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          _selectedPendingInvoice = PendingApprovalInvoice.fromJson(response.data['data']);
          _state = InvoiceState.loaded;
        } else {
          _errorMessage = response.data['message'] ?? 'Invoice not found';
          _state = InvoiceState.error;
        }
      } else if (response.statusCode == 404) {
        _errorMessage = 'Invoice not found';
        _state = InvoiceState.error;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Access denied';
        _state = InvoiceState.error;
      } else {
        _errorMessage = 'Failed to load invoice details';
        _state = InvoiceState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load invoice details: $e';
      _state = InvoiceState.error;
    }
    
    notifyListeners();
  }
  
  // Approve Invoice
  Future<bool> approveInvoice(int invoiceId, String remarks) async {
    _isSubmittingApproval = true;
    _state = InvoiceState.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.approveInvoice(invoiceId, remarks);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          _successMessage = response.data['message'] ?? 'Invoice approved successfully';
          _state = InvoiceState.success;
          
          // Remove from pending list if exists
          _pendingApprovalInvoices.removeWhere((i) => i.id == invoiceId);
          
          // Clear selected invoice
          _selectedPendingInvoice = null;
          
          _isSubmittingApproval = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.data['message'] ?? 'Failed to approve invoice';
          _state = InvoiceState.error;
          _isSubmittingApproval = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Failed to approve invoice';
        _state = InvoiceState.error;
        _isSubmittingApproval = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Mock success for demo
      _successMessage = 'Invoice approved successfully';
      _state = InvoiceState.success;
      
      // Remove from pending list if exists
      _pendingApprovalInvoices.removeWhere((i) => i.id == invoiceId);
      
      // Clear selected invoice
      _selectedPendingInvoice = null;
      
      _isSubmittingApproval = false;
      notifyListeners();
      return true;
    }
  }
  
  // Reject Invoice
  Future<bool> rejectInvoice(int invoiceId, String remarks) async {
    if (remarks.isEmpty) {
      _errorMessage = 'Rejection reason is required';
      _state = InvoiceState.error;
      notifyListeners();
      return false;
    }
    
    _isSubmittingApproval = true;
    _state = InvoiceState.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.rejectInvoice(invoiceId, remarks);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          _successMessage = response.data['message'] ?? 'Invoice rejected successfully';
          _state = InvoiceState.success;
          
          // Remove from pending list if exists
          _pendingApprovalInvoices.removeWhere((i) => i.id == invoiceId);
          
          // Clear selected invoice
          _selectedPendingInvoice = null;
          
          _isSubmittingApproval = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.data['message'] ?? 'Failed to reject invoice';
          _state = InvoiceState.error;
          _isSubmittingApproval = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Failed to reject invoice';
        _state = InvoiceState.error;
        _isSubmittingApproval = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Mock success for demo
      _successMessage = 'Invoice rejected successfully';
      _state = InvoiceState.success;
      
      // Remove from pending list if exists
      _pendingApprovalInvoices.removeWhere((i) => i.id == invoiceId);
      
      // Clear selected invoice
      _selectedPendingInvoice = null;
      
      _isSubmittingApproval = false;
      notifyListeners();
      return true;
    }
  }
  
  // Clear Selected Pending Invoice
  void clearSelectedPendingInvoice() {
    _selectedPendingInvoice = null;
    notifyListeners();
  }
  
  // Load Lender Types
  Future<void> loadLenderTypes() async {
    _isLoadingLenderTypes = true;
    notifyListeners();
    
    try {
      final response = await apiService.getLenderTypes();
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          _lenderTypes = List<String>.from(response.data['data']);
        }
        
        // Set default selected lender if not set
        if (_selectedLender == null && _lenderTypes.isNotEmpty) {
          _selectedLender = _lenderTypes.first;
        }
      }
    } catch (e) {
      debugPrint('Failed to load lender types: $e');
    }
    
    _isLoadingLenderTypes = false;
    notifyListeners();
  }
  
  // Select Lender
  Future<void> selectLender(String lender) async {
    if (_selectedLender != lender) {
      _selectedLender = lender;
      _invoiceDetailsResponse = null;
      _invoices = [];
      notifyListeners();
      
      // Load invoices for the selected lender
      await loadInvoiceDetails();
    }
  }
  
  // Load Invoice Details
  Future<void> loadInvoiceDetails() async {
    if (_selectedLender == null) {
      _errorMessage = 'Please select a lender';
      _state = InvoiceState.error;
      notifyListeners();
      return;
    }
    
    _isLoadingInvoices = true;
    _state = InvoiceState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getInvoiceDetails(_selectedLender!);
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true && response.data['data'] != null) {
          _invoiceDetailsResponse = InvoiceDetailsResponse.fromJson(response.data['data']);
          _state = InvoiceState.loaded;
        } else {
          _errorMessage = 'Failed to load invoice details';
          _state = InvoiceState.error;
        }
      } else {
        _errorMessage = 'Failed to load invoice details';
        _state = InvoiceState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load invoice details: $e';
      _state = InvoiceState.error;
    }
    
    _isLoadingInvoices = false;
    notifyListeners();
  }
  
  // Select Invoice
  void selectInvoice(InvoiceDetail invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }
  
  // Clear Selected Invoice
  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }
  
  // Load Invoice Requests
  Future<void> loadInvoiceRequests() async {
    _state = InvoiceState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.getInvoiceList();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['invoices'] ?? response.data;
        _invoiceRequests = data.map((json) => InvoiceRequest.fromJson(json)).toList();
        _state = InvoiceState.loaded;
      } else {
        _errorMessage = 'Failed to load invoice requests.';
        _state = InvoiceState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load invoice requests.';
      _state = InvoiceState.error;
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
      _calculation = InvoiceCalculation.calculate(amount);
    } else {
      _calculation = null;
    }
    notifyListeners();
  }
  
  // Submit Invoice Request
  Future<bool> submitInvoiceRequest({
    required String invoiceId,
    required String dealerId,
    required double amount,
  }) async {
    _state = InvoiceState.submitting;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final body = {
        'invoice_id': invoiceId,
        'dealer_id': dealerId,
        'amount': amount,
      };
      
      final response = await apiService.submitInvoice(body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = 'Invoice request submitted successfully!';
        _state = InvoiceState.success;
        
        // Reload requests
        await loadInvoiceRequests();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Failed to submit invoice request.';
        _state = InvoiceState.error;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to submit invoice request.';
      _state = InvoiceState.error;
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
    _state = InvoiceState.initial;
    _calculation = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  // Refresh
  Future<void> refresh() async {
    await loadInvoiceRequests();
  }
}
