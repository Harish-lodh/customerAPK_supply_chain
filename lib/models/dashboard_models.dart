class Dashboard {
  final double sanctionedLimit;
  final double availableLimit;
  final double utilizedAmount;
  final int activeLoansCount;
  final double overdueAmount;
  final DateTime? nextEmiDate;
  final List<QuickAction> quickActions;
  
  Dashboard({
    required this.sanctionedLimit,
    required this.availableLimit,
    required this.utilizedAmount,
    required this.activeLoansCount,
    required this.overdueAmount,
    this.nextEmiDate,
    required this.quickActions,
  });
  
  double get utilizationPercentage {
    if (sanctionedLimit == 0) return 0;
    return (utilizedAmount / sanctionedLimit) * 100;
  }
  
  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      sanctionedLimit: (json['sanctioned_limit'] ?? 0).toDouble(),
      availableLimit: (json['available_limit'] ?? 0).toDouble(),
      utilizedAmount: (json['utilized_amount'] ?? 0).toDouble(),
      activeLoansCount: json['active_loans_count'] ?? 0,
      overdueAmount: (json['overdue_amount'] ?? 0).toDouble(),
      nextEmiDate: json['next_emi_date'] != null 
          ? DateTime.parse(json['next_emi_date']) 
          : null,
      quickActions: (json['quick_actions'] as List<dynamic>?)
          ?.map((e) => QuickAction.fromJson(e))
          .toList() ?? [],
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
