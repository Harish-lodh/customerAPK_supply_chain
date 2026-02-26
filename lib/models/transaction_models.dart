class Transaction {
  final String id;
  final String transactionId;
  final String type;
  final double amount;
  final DateTime transactionDate;
  final String status;
  final String? loanNumber;
  final String? utrNumber;
  final String? referenceNumber;
  final String? description;
  final String? remarks;
  
  Transaction({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.status,
    this.loanNumber,
    this.utrNumber,
    this.referenceNumber,
    this.description,
    this.remarks,
  });
  
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      loanNumber: json['loan_number'],
      utrNumber: json['utr_number'],
      referenceNumber: json['reference_number'],
      description: json['description'],
      remarks: json['remarks'],
    );
  }
  
  // Mock data for demo
  factory Transaction.mock(int index) {
    final types = ['DISBURSEMENT', 'REPAYMENT', 'INTEREST', 'PROCESSING_FEE'];
    final statuses = ['SUCCESS', 'PENDING', 'SUCCESS', 'SUCCESS'];
    
    return Transaction(
      id: 'TX$index',
      transactionId: 'TXN/2024/${index.toString().padLeft(6, '0')}',
      type: types[index % 4],
      amount: [500000.0, 250000.0, 25000.0, 2500.0][index % 4],
      transactionDate: DateTime.now().subtract(Duration(days: index * 2)),
      status: statuses[index % 4],
      loanNumber: 'SCF/2024/00${(index % 3) + 1}',
      utrNumber: 'UTR${DateTime.now().millisecondsSinceEpoch}$index',
      referenceNumber: 'REF${index + 1000}',
      description: types[index % 4] == 'DISBURSEMENT' 
          ? 'Loan Disbursement' 
          : types[index % 4] == 'REPAYMENT'
              ? 'EMI Payment'
              : types[index % 4] == 'INTEREST'
                  ? 'Interest Payment'
                  : 'Processing Fee',
      remarks: 'Transaction completed successfully',
    );
  }
  
  String get typeDisplay {
    switch (type) {
      case 'DISBURSEMENT':
        return 'Disbursement';
      case 'REPAYMENT':
        return 'Repayment';
      case 'INTEREST':
        return 'Interest';
      case 'PROCESSING_FEE':
        return 'Processing Fee';
      default:
        return type;
    }
  }
  
  bool get isCredit => type == 'DISBURSEMENT';
  bool get isDebit => type == 'REPAYMENT' || type == 'INTEREST' || type == 'PROCESSING_FEE';
}

/// Collection Transaction model for /customers/transactions/by-lan API
/// Response format: { "success": true, "data": [{ "collection_date": "...", "collection_amount": ..., "collection_utr": "..." }] }
class CollectionTransaction {
  final DateTime collectionDate;
  final double collectionAmount;
  final String? collectionUtr;
  
  CollectionTransaction({
    required this.collectionDate,
    required this.collectionAmount,
    this.collectionUtr,
  });
  
  factory CollectionTransaction.fromJson(Map<String, dynamic> json) {
    return CollectionTransaction(
      collectionDate: DateTime.parse(json['collection_date'] ?? DateTime.now().toIso8601String()),
      collectionAmount: (json['collection_amount'] ?? 0).toDouble(),
      collectionUtr: json['collection_utr'],
    );
  }
  
  // Mock data for demo
  factory CollectionTransaction.mock(int index) {
    return CollectionTransaction(
      collectionDate: DateTime.now().subtract(Duration(days: index * 3)),
      collectionAmount: [7000000.0, 5000000.0, 3000000.0, 2500000.0][index % 4],
      collectionUtr: 'UTR${555550 + index}',
    );
  }
}

class TransactionList {
  final List<Transaction> transactions;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
  
  TransactionList({
    required this.transactions,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
  
  factory TransactionList.fromJson(Map<String, dynamic> json) {
    return TransactionList(
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ?? [],
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      hasMore: json['has_more'] ?? false,
    );
  }
  
  // Mock data for demo
  factory TransactionList.mock({int page = 1, int pageSize = 20}) {
    List<Transaction> transactions = [];
    for (int i = 0; i < pageSize; i++) {
      transactions.add(Transaction.mock(i + ((page - 1) * pageSize)));
    }
    
    return TransactionList(
      transactions: transactions,
      totalCount: 100,
      page: page,
      pageSize: pageSize,
      hasMore: page < 5,
    );
  }
}

class TransactionReceipt {
  final String transactionId;
  final String loanNumber;
  final String transactionType;
  final double amount;
  final DateTime transactionDate;
  final String status;
  final String? utrNumber;
  final String? paymentMode;
  final String? bankName;
  final String? accountNumber;
  final String? remarks;
  final String? companyName;
  final String? companyGst;
  
  TransactionReceipt({
    required this.transactionId,
    required this.loanNumber,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.status,
    this.utrNumber,
    this.paymentMode,
    this.bankName,
    this.accountNumber,
    this.remarks,
    this.companyName,
    this.companyGst,
  });
  
  factory TransactionReceipt.fromJson(Map<String, dynamic> json) {
    return TransactionReceipt(
      transactionId: json['transaction_id'] ?? '',
      loanNumber: json['loan_number'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      utrNumber: json['utr_number'],
      paymentMode: json['payment_mode'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      remarks: json['remarks'],
      companyName: json['company_name'],
      companyGst: json['company_gst'],
    );
  }
}

/// Transaction Detail with Allocation data
/// GET /customers/transaction-detail?lan={lan}&utr={utr}
class TransactionDetail {
  final String lan;
  final String collectionUtr;
  final double totalCollected;
  final AllocationBreakup allocationBreakup;
  final List<InvoiceAllocation> invoiceWiseAllocation;
  
  TransactionDetail({
    required this.lan,
    required this.collectionUtr,
    required this.totalCollected,
    required this.allocationBreakup,
    required this.invoiceWiseAllocation,
  });
  
  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    final allocationBreakupJson = json['allocation_breakup'] ?? {};
    final invoiceList = json['invoice_wise_allocation'] as List<dynamic>? ?? [];
    
    return TransactionDetail(
      lan: json['lan'] ?? '',
      collectionUtr: json['collection_utr'] ?? '',
      totalCollected: (json['total_collected'] ?? 0).toDouble(),
      allocationBreakup: AllocationBreakup.fromJson(allocationBreakupJson),
      invoiceWiseAllocation: invoiceList
          .map((e) => InvoiceAllocation.fromJson(e))
          .toList(),
    );
  }
}

class AllocationBreakup {
  final double allocatedPrincipal;
  final double allocatedInterest;
  final double allocatedPenalInterest;
  final double excessPayment;
  
  AllocationBreakup({
    required this.allocatedPrincipal,
    required this.allocatedInterest,
    required this.allocatedPenalInterest,
    required this.excessPayment,
  });
  
  factory AllocationBreakup.fromJson(Map<String, dynamic> json) {
    return AllocationBreakup(
      allocatedPrincipal: (json['allocated_principal'] ?? 0).toDouble(),
      allocatedInterest: (json['allocated_interest'] ?? 0).toDouble(),
      allocatedPenalInterest: (json['allocated_penal_interest'] ?? 0).toDouble(),
      excessPayment: (json['excess_payment'] ?? 0).toDouble(),
    );
  }
}

class InvoiceAllocation {
  final String invoiceNumber;
  final double allocatedPrincipal;
  final double allocatedInterest;
  final double allocatedPenalInterest;
  
  InvoiceAllocation({
    required this.invoiceNumber,
    required this.allocatedPrincipal,
    required this.allocatedInterest,
    required this.allocatedPenalInterest,
  });
  
  factory InvoiceAllocation.fromJson(Map<String, dynamic> json) {
    return InvoiceAllocation(
      invoiceNumber: json['invoice_number'] ?? '',
      allocatedPrincipal: (json['allocated_principal'] ?? 0).toDouble(),
      allocatedInterest: (json['allocated_interest'] ?? 0).toDouble(),
      allocatedPenalInterest: (json['allocated_penal_interest'] ?? 0).toDouble(),
    );
  }
}
