class AppConstants {
  AppConstants._();

  // API Base URLs
  static const String baseUrl = 'https://api.fintree-scf.com/v1';
  static const String stagingUrl = 'https://staging-api.fintree-scf.com/v1';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String otpEndpoint = '/auth/otp';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  static const String dashboardEndpoint = '/customers/dashboard';
  static const String drawdownEndpoint = '/customers/drawdown';
  static const String drawdownListEndpoint = '/customers/drawdown/list';
  static const String loansEndpoint = '/customers/loans';
  static const String loanDetailEndpoint = '/customers/loans/detail';
  static const String loanScheduleEndpoint = '/customers/loans/schedule';
  static const String loanStatementEndpoint = '/customers/loans/statement';
  static const String loanForeclosurePreviewEndpoint = '/customers/loans/foreclosure-preview';
  static const String transactionsEndpoint = '/customers/transactions';
  static const String notificationsEndpoint = '/customers/notifications';
  static const String profileEndpoint = '/customers/profile';
  static const String bankDetailsEndpoint = '/customers/profile/bank-details';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // App Constants
  static const int otpLength = 6;
  static const int otpValiditySeconds = 300;
  static const int tokenRefreshBufferSeconds = 60;
  
  // Processing Fee Percentage
  static const double processingFeePercentage = 0.5;
  static const double minimumProcessingFee = 250.0;
  
  // Loan Status
  static const String statusActive = 'ACTIVE';
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusRejected = 'REJECTED';
  static const String statusDisbursed = 'DISBURSED';
  static const String statusClosed = 'CLOSED';
  
  // Transaction Types
  static const String transactionDisbursement = 'DISBURSEMENT';
  static const String transactionRepayment = 'REPAYMENT';
  static const String transactionInterest = 'INTEREST';
  static const String transactionProcessingFee = 'PROCESSING_FEE';
}
