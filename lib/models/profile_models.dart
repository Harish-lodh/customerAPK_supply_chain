class CompanyProfile {
  final String id;
  final String companyName;
  final String email;
  final String mobileNumber;
  final String? panNumber;
  final String? gstNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? businessType;
  final DateTime? incorporationDate;
  
  CompanyProfile({
    required this.id,
    required this.companyName,
    required this.email,
    required this.mobileNumber,
    this.panNumber,
    this.gstNumber,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.businessType,
    this.incorporationDate,
  });
  
  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      panNumber: json['pan_number'],
      gstNumber: json['gst_number'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      businessType: json['business_type'],
      incorporationDate: json['incorporation_date'] != null 
          ? DateTime.parse(json['incorporation_date']) 
          : null,
    );
  }
  
  // Mock data for demo
  factory CompanyProfile.mock() {
    return CompanyProfile(
      id: 'CMP001',
      companyName: 'ABC Traders Pvt Ltd',
      email: 'contact@abctraders.com',
      mobileNumber: '+91 9876543210',
      panNumber: 'AABCU9600R1ZN',
      gstNumber: '29AABCU9600R1ZN',
      address: '123 Business Park, Main Road',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001',
      businessType: 'Trading',
      incorporationDate: DateTime(2015, 4, 1),
    );
  }
}

class BankDetails {
  final String id;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifscCode;
  final String accountType;
  final bool isPrimary;
  final DateTime? verifiedAt;
  
  BankDetails({
    required this.id,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
    required this.isPrimary,
    this.verifiedAt,
  });
  
  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] ?? '',
      bankName: json['bank_name'] ?? '',
      branchName: json['branch_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountType: json['account_type'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      verifiedAt: json['verified_at'] != null 
          ? DateTime.parse(json['verified_at']) 
          : null,
    );
  }
  
  // Mock data for demo
  factory BankDetails.mock() {
    return BankDetails(
      id: 'BANK001',
      bankName: 'HDFC Bank',
      branchName: 'MG Road Branch',
      accountNumber: '50200012345678',
      ifscCode: 'HDFC0001234',
      accountType: 'Current',
      isPrimary: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }
  
  String get maskedAccountNumber {
    if (accountNumber.length > 4) {
      return '****${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }
}

class SupportContact {
  final String email;
  final String phone;
  final String? whatsapp;
  final String? workingHours;
  
  SupportContact({
    required this.email,
    required this.phone,
    this.whatsapp,
    this.workingHours,
  });
  
  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'],
      workingHours: json['working_hours'],
    );
  }
  
  // Mock data for demo
  factory SupportContact.mock() {
    return SupportContact(
      email: 'support@fintree-scf.com',
      phone: '+91 1800 123 4567',
      whatsapp: '+91 9876543210',
      workingHours: 'Mon - Sat, 9:00 AM - 6:00 PM',
    );
  }
}
