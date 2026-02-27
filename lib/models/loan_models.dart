class Loan {
  final String id;
  final String loanNumber;
  final String productType;
  final double sanctionedAmount;
  final double utilizedAmount;
  final double outstandingAmount;
  final String status;
  final DateTime disbursementDate;
  final DateTime? maturityDate;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final String? dealerName;
  final List<EmiSchedule> emiSchedule;
  
  Loan({
    required this.id,
    required this.loanNumber,
    required this.productType,
    required this.sanctionedAmount,
    required this.utilizedAmount,
    required this.outstandingAmount,
    required this.status,
    required this.disbursementDate,
    this.maturityDate,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    this.dealerName,
    this.emiSchedule = const [],
  });
  
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? '',
      loanNumber: json['lan'] ?? '',
      productType: json['product_type'] ?? 'Loan',
      sanctionedAmount: _parseDouble(json['sanction_amount']),
      utilizedAmount: _parseDouble(json['utilized_sanction_limit']),
      outstandingAmount: _parseDouble(json['unutilization_sanction_limit']),
      status: 'ACTIVE',
      disbursementDate: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      maturityDate: null,
      interestRate: _parseDouble(json['interest_rate']),
      tenureMonths: json['tenure_months'] ?? 0,
      emiAmount: 0,
      dealerName: null,
      emiSchedule: const [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  
  // Mock data for demo
  factory Loan.mock(int index) {
    final now = DateTime.now();
    return Loan(
      id: 'LN$index',
      loanNumber: 'SCF/2024/00$index',
      productType: 'Invoice Financing',
      sanctionedAmount: 5000000,
      utilizedAmount: 3500000,
      outstandingAmount: 2800000,
      status: 'ACTIVE',
      disbursementDate: now.subtract(Duration(days: 90 - (index * 30))),
      maturityDate: now.add(Duration(days: 270 - (index * 30))),
      interestRate: 12.5,
      tenureMonths: 12,
      emiAmount: 250000,
      dealerName: 'Dealer Name $index',
      emiSchedule: _generateMockEmiSchedule(now),
    );
  }
  
  static List<EmiSchedule> _generateMockEmiSchedule(DateTime startDate) {
    List<EmiSchedule> schedule = [];
    for (int i = 1; i <= 12; i++) {
      schedule.add(EmiSchedule(
        emiNumber: i,
        dueDate: startDate.add(Duration(days: 30 * i)),
        amount: 250000,
        principal: 200000,
        interest: 50000,
        status: i <= 3 ? 'PAID' : 'PENDING',
      ));
    }
    return schedule;
  }
}

class EmiSchedule {
  final int emiNumber;
  final DateTime dueDate;
  final double amount;
  final double principal;
  final double interest;
  final String status;
  
  EmiSchedule({
    required this.emiNumber,
    required this.dueDate,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.status,
  });
  
  factory EmiSchedule.fromJson(Map<String, dynamic> json) {
    return EmiSchedule(
      emiNumber: json['emi_number'] ?? 0,
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0).toDouble(),
      principal: (json['principal'] ?? 0).toDouble(),
      interest: (json['interest'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
    );
  }
}

// New EMI Schedule Response model for the new API format
class EmiScheduleResponse {
  final String invoiceNumber;
  final DateTime invoiceDueDate;
  final DateTime disbursementDate;
  final double totalAmountDemand;
  final double remainingPrincipal;
  final double remainingInterest;
  final double remainingPenalInterest;
  final double overdueAmountDemand;
  final String status;
  
  EmiScheduleResponse({
    required this.invoiceNumber,
    required this.invoiceDueDate,
    required this.disbursementDate,
    required this.totalAmountDemand,
    required this.remainingPrincipal,
    required this.remainingInterest,
    required this.remainingPenalInterest,
    required this.overdueAmountDemand,
    required this.status,
  });
  
  factory EmiScheduleResponse.fromJson(Map<String, dynamic> json) {
    return EmiScheduleResponse(
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDueDate: DateTime.parse(json['invoice_due_date'] ?? DateTime.now().toIso8601String()),
      disbursementDate: DateTime.parse(json['disbursement_date'] ?? DateTime.now().toIso8601String()),
      totalAmountDemand: _parseDouble(json['total_amount_demand']),
      remainingPrincipal: _parseDouble(json['remaining_disbursement_amount']),
      remainingInterest: _parseDouble(json['cumulate_interest_demand']),
      remainingPenalInterest: _parseDouble(json['cumelate_penal_interest_demand']),
      overdueAmountDemand: _parseDouble(json['overdue_amount_demand']),
      status: json['status'] ?? 'Due',
    );
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class LoanStatement {
  final String loanId;
  final String loanNumber;
  final DateTime fromDate;
  final DateTime toDate;
  final double openingBalance;
  final double closingBalance;
  final double totalDisbursement;
  final double totalRepayment;
  final List<StatementEntry> entries;
  
  LoanStatement({
    required this.loanId,
    required this.loanNumber,
    required this.fromDate,
    required this.toDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalDisbursement,
    required this.totalRepayment,
    required this.entries,
  });
  
  factory LoanStatement.fromJson(Map<String, dynamic> json) {
    return LoanStatement(
      loanId: json['loan_id'] ?? '',
      loanNumber: json['loan_number'] ?? '',
      fromDate: DateTime.parse(json['from_date'] ?? DateTime.now().toIso8601String()),
      toDate: DateTime.parse(json['to_date'] ?? DateTime.now().toIso8601String()),
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      closingBalance: (json['closing_balance'] ?? 0).toDouble(),
      totalDisbursement: (json['total_disbursement'] ?? 0).toDouble(),
      totalRepayment: (json['total_repayment'] ?? 0).toDouble(),
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => StatementEntry.fromJson(e))
          .toList() ?? [],
    );
  }
}

class StatementEntry {
  final DateTime date;
  final String description;
  final double debit;
  final double credit;
  final double balance;
  final String? utrNumber;
  
  StatementEntry({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
    this.utrNumber,
  });
  
  factory StatementEntry.fromJson(Map<String, dynamic> json) {
    return StatementEntry(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      utrNumber: json['utr_number'],
    );
  }
}

class ForeclosurePreview {
  final String loanId;
  final double outstandingPrincipal;
  final double interestOutstanding;
  final double foreclosureCharges;
  final double gstAmount;
  final double totalForeclosureAmount;
  
  ForeclosurePreview({
    required this.loanId,
    required this.outstandingPrincipal,
    required this.interestOutstanding,
    required this.foreclosureCharges,
    required this.gstAmount,
    required this.totalForeclosureAmount,
  });
  
  factory ForeclosurePreview.fromJson(Map<String, dynamic> json) {
    return ForeclosurePreview(
      loanId: json['loan_id'] ?? '',
      outstandingPrincipal: (json['outstanding_principal'] ?? 0).toDouble(),
      interestOutstanding: (json['interest_outstanding'] ?? 0).toDouble(),
      foreclosureCharges: (json['foreclosure_charges'] ?? 0).toDouble(),
      gstAmount: (json['gst_amount'] ?? 0).toDouble(),
      totalForeclosureAmount: (json['total_foreclosure_amount'] ?? 0).toDouble(),
    );
  }
}
