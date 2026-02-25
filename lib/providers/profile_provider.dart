import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/session_service.dart';
import '../models/profile_models.dart';

enum ProfileState {
  initial,
  loading,
  loaded,
  error,
}

class ProfileProvider extends ChangeNotifier {
  final ApiService apiService;
  
  ProfileState _state = ProfileState.initial;
  CompanyProfile? _companyProfile;
  BankDetails? _bankDetails;
  SupportContact? _supportContact;
  String? _errorMessage;
  
  ProfileProvider({required this.apiService});
  
  // Getters
  ProfileState get state => _state;
  CompanyProfile? get companyProfile => _companyProfile;
  BankDetails? get bankDetails => _bankDetails;
  SupportContact? get supportContact => _supportContact;
  String? get errorMessage => _errorMessage;
  
  // Load Profile from backend
  Future<void> loadProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Get userId from session
      final userId = await SessionService.getCustomerId();
      
      // Check if user is logged in
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Build dynamic endpoint
      final endpoint = '/customers/$userId/customerDetails';
      
      // Make API call to fetch profile data
      final response = await apiService.get(endpoint);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Check if response has success flag
        if (data['success'] == true && data['data'] != null) {
          final profileData = data['data'];
          
          // Parse company profile
          _companyProfile = CompanyProfile(
            id: profileData['id']?.toString() ?? '',
            companyName: profileData['companyName'] ?? '',
            email: profileData['email'] ?? '',
            mobileNumber: profileData['mobile'] ?? '',
            panNumber: profileData['pan'],
            gstNumber: profileData['gstNumber'],
            address: profileData['addresses']?.isNotEmpty == true 
                ? profileData['addresses'][0]['fullAddress'] 
                : null,
            city: profileData['addresses']?.isNotEmpty == true 
                ? profileData['addresses'][0]['city'] 
                : null,
            state: profileData['addresses']?.isNotEmpty == true 
                ? profileData['addresses'][0]['state'] 
                : null,
            pincode: profileData['addresses']?.isNotEmpty == true 
                ? profileData['addresses'][0]['pincode'] 
                : null,
          );
          
          // Parse bank details
          if (profileData['bankAccountNo'] != null && 
              profileData['bankAccountNo'].toString().isNotEmpty) {
            _bankDetails = BankDetails(
              id: '',
              bankName: profileData['bankName'] ?? '',
              branchName: profileData['bankBranch'] ?? '',
              accountNumber: profileData['bankAccountNo'] ?? '',
              ifscCode: profileData['bankIfscCode'] ?? '',
              accountType: profileData['bankType'] ?? 'Saving',
              isPrimary: true,
            );
          }
          
          // Support contact - can be fetched from separate endpoint or use defaults
          _supportContact = SupportContact(
            email: 'support@fintree-scf.com',
            phone: '+91 1800 123 4567',
            whatsapp: '+91 9876543210',
            workingHours: 'Mon - Sat, 9:00 AM - 6:00 PM',
          );
          
          _state = ProfileState.loaded;
        } else {
          throw Exception(data['message'] ?? 'Failed to load profile');
        }
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.error;
    }
    notifyListeners();
  }
  
  // Refresh Profile
  Future<void> refresh() async {
    await loadProfile();
  }
  
  // Load Bank Details from API
  Future<void> loadBankDetails() async {
    try {
      final response = await apiService.getBankDetails();
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _bankDetails = BankDetails(
          id: data['id']?.toString() ?? '',
          bankName: data['bank_name'] ?? '',
          branchName: data['branch_name'] ?? '',
          accountNumber: data['account_number'] ?? '',
          ifscCode: data['ifsc_code'] ?? '',
          accountType: data['account_type'] ?? 'Saving',
          isPrimary: data['is_primary'] ?? true,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load bank details.';
      notifyListeners();
    }
  }
}
