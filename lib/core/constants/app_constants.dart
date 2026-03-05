class AppConstants {
  AppConstants._();

  // API Base URLs
  static const String baseUrl = 'https://api.fintree-scf.com/v1';
  static const String stagingUrl = 'https://staging-api.fintree-scf.com/v1';
  
  // API Endpoints

  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  static const String dashboardEndpoint = '/lms-customers/dashboard';
  static const String invoiceEndpoint = '/lms-customers/invoice';
  static const String invoiceListEndpoint = '/lms-customers/invoice/list';
  static const String loansEndpoint = '/lms-customers/loans';
  static const String loanDetailEndpoint = '/lms-customers/loans/detail';
  static const String loanScheduleEndpoint = '/lms-customers/loans/schedule';
  static const String loanStatementEndpoint = '/lms-customers/loans/statement';
  static const String loanForeclosurePreviewEndpoint = '/lms-customers/loans/foreclosure-preview';
  static const String transactionsEndpoint = '/lms-customers/transactions/getRepayments';
  static const String transactionDetailEndpoint = '/lms-customers/transaction-detail';
  static const String lenderTypesEndpoint = '/lms-customers/lan';
  static const String notificationsEndpoint = '/lms-customers/notifications';
  static const String profileEndpoint = '/lms-customers/profile';
  static const String bankDetailsEndpoint = '/lms-customers/profile/bank-details';
  
  // Invoice Details Endpoint
  static const String invoiceDetailsEndpoint = '/lms-customers/invoice-details';
  
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
