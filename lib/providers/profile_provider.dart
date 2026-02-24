import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
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
  
  // Load Profile
  Future<void> loadProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API calls
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _companyProfile = CompanyProfile.mock();
      _bankDetails = BankDetails.mock();
      _supportContact = SupportContact.mock();
      
      _state = ProfileState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
      _state = ProfileState.error;
    }
    notifyListeners();
  }
  
  // Refresh Profile
  Future<void> refresh() async {
    await loadProfile();
  }
}
