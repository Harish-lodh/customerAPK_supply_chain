class Dashboard {
  final double sanctionedLimit;
  final double availableLimit;
  final double utilizedAmount;
  final int activeLoansCount;
  final double overdueAmount;
  final DateTime? nextEmiDate;
  final List<QuickAction> quickActions;
  
  // New fields from API
  final int totalLoans;
  final double totalDisbursed;
  final double totalOutstanding;
  final List<RecentRepayment> recentRepayments;
  final int unreadNotifications;
  final bool isLmsData;
  
  Dashboard({
    required this.sanctionedLimit,
    required this.availableLimit,
    required this.utilizedAmount,
    required this.activeLoansCount,
    required this.overdueAmount,
    this.nextEmiDate,
    required this.quickActions,
    required this.totalLoans,
    required this.totalDisbursed,
    required this.totalOutstanding,
    required this.recentRepayments,
    required this.unreadNotifications,
    required this.isLmsData,
  });
  
  double get utilizationPercentage {
    if (sanctionedLimit == 0) return 0;
    return (utilizedAmount / sanctionedLimit) * 100;
  }
  
  factory Dashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return Dashboard(
      sanctionedLimit: (data['totalSanctioned'] ?? 0).toDouble(),
      availableLimit: (data['totalAvailable'] ?? 0).toDouble(),
      utilizedAmount: (data['totalUtilized'] ?? 0).toDouble(),
      activeLoansCount: data['activeLoans'] ?? data['active_loans_count'] ?? 0,
      overdueAmount: (data['totalOutstanding'] ?? data['overdue_amount'] ?? 0).toDouble(),
      nextEmiDate: data['next_emi_date'] != null 
          ? DateTime.parse(data['next_emi_date']) 
          : null,
      quickActions: (data['quick_actions'] as List<dynamic>?)
          ?.map((e) => QuickAction.fromJson(e))
          .toList() ?? [],
      totalLoans: data['totalLoans'] ?? data['total_loans'] ?? 0,
      totalDisbursed: (data['totalDisbursed'] ?? 0).toDouble(),
      totalOutstanding: (data['totalOutstanding'] ?? 0).toDouble(),
      recentRepayments: (data['recentRepayments'] as List<dynamic>?)
          ?.map((e) => RecentRepayment.fromJson(e))
          .toList() ?? [],
      unreadNotifications: data['unreadNotifications'] ?? 0,
      isLmsData: data['isLmsData'] ?? data['is_lms_data'] ?? false,
    );
  }
  
  // Mock data for demo
  factory Dashboard.mock() {
    return Dashboard(
      sanctionedLimit: 10000000,
      availableLimit: 6500000,
      utilizedAmount: 3500000,
      activeLoansCount: 3,
      overdueAmount: 0,
      nextEmiDate: DateTime.now().add(const Duration(days: 15)),
      quickActions: [
        QuickAction(id: '1', title: 'Apply Drawdown', icon: 'drawdown'),
        QuickAction(id: '2', title: 'View Statement', icon: 'statement'),
        QuickAction(id: '3', title: 'Repay Now', icon: 'repayment'),
        QuickAction(id: '4', title: 'Foreclosure', icon: 'foreclosure'),
      ],
      totalLoans: 3,
      totalDisbursed: 15000000,
      totalOutstanding: 3500000,
      recentRepayments: [],
      unreadNotifications: 0,
      isLmsData: true,
    );
  }
}

class QuickAction {
  final String id;
  final String title;
  final String icon;
  
  QuickAction({
    required this.id,
    required this.title,
    required this.icon,
  });
  
  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class RecentRepayment {
  final String id;
  final String lan;
  final DateTime collectionDate;
  final double collectionAmount;
  
  RecentRepayment({
    required this.id,
    required this.lan,
    required this.collectionDate,
    required this.collectionAmount,
  });
  
  factory RecentRepayment.fromJson(Map<String, dynamic> json) {
    return RecentRepayment(
      id: json['id'] ?? '',
      lan: json['lan'] ?? '',
      collectionDate: json['collection_date'] != null 
          ? DateTime.parse(json['collection_date']) 
          : DateTime.now(),
      collectionAmount: double.tryParse(json['collection_amount']?.toString() ?? '0') ?? 0,
    );
  }
}

class LimitUtilization {
  final double sanctioned;
  final double utilized;
  final double available;
  
  LimitUtilization({
    required this.sanctioned,
    required this.utilized,
    required this.available,
  });
  
  factory LimitUtilization.fromDashboard(Dashboard dashboard) {
    return LimitUtilization(
      sanctioned: dashboard.sanctionedLimit,
      utilized: dashboard.utilizedAmount,
      available: dashboard.availableLimit,
    );
  }
}
