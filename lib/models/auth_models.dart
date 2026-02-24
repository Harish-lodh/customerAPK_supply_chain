class User {
  final String id;
  final String mobileNumber;
  final String companyName;
  final String email;
  final String? panNumber;
  final String? gstNumber;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.mobileNumber,
    required this.companyName,
    required this.email,
    this.panNumber,
    this.gstNumber,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      panNumber: json['pan_number'],
      gstNumber: json['gst_number'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile_number': mobileNumber,
      'company_name': companyName,
      'email': email,
      'pan_number': panNumber,
      'gst_number': gstNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class LoginRequest {
  final String mobileNumber;
  final String? password;
  final String? otp;
  final bool isOtpLogin;
  
  LoginRequest({
    required this.mobileNumber,
    this.password,
    this.otp,
    this.isOtpLogin = false,
  });
  
  Map<String, dynamic> toJson() {
    if (isOtpLogin) {
      return {
        'mobile_number': mobileNumber,
        'otp': otp,
      };
    }
    return {
      'mobile_number': mobileNumber,
      'password': password,
    };
  }
}
