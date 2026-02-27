class InvoiceRequest {
  final String id;
  final String requestNumber;
  final String? invoiceNumber;
  final String? dealerId;
  final String? dealerName;
  final double amount;
  final double processingFee;
  final double gstAmount;
  final double netDisbursement;
  final String status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final DateTime? disbursementDate;
  final String? utrNumber;
  final String? remarks;
  
  InvoiceRequest({
    required this.id,
    required this.requestNumber,
    this.invoiceNumber,
    this.dealerId,
    this.dealerName,
    required this.amount,
    required this.processingFee,
    required this.gstAmount,
    required this.netDisbursement,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.disbursementDate,
    this.utrNumber,
    this.remarks,
  });
  
  factory InvoiceRequest.fromJson(Map<String, dynamic> json) {
    return InvoiceRequest(
      id: json['id'] ?? '',
      requestNumber: json['request_number'] ?? '',
      invoiceNumber: json['invoice_number'],
      dealerId: json['dealer_id'],
      dealerName: json['dealer_name'],
      amount: (json['amount'] ?? 0).toDouble(),
      processingFee: (json['processing_fee'] ?? 0).toDouble(),
      gstAmount: (json['gst_amount'] ?? 0).toDouble(),
      netDisbursement: (json['net_disbursement'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      requestDate: DateTime.parse(json['request_date'] ?? DateTime.now().toIso8601String()),
      approvalDate: json['approval_date'] != null 
          ? DateTime.parse(json['approval_date']) 
          : null,
      disbursementDate: json['disbursement_date'] != null 
          ? DateTime.parse(json['disbursement_date']) 
          : null,
      utrNumber: json['utr_number'],
      remarks: json['remarks'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'dealer_id': dealerId,
      'amount': amount,
    };
  }
  
  // Mock data for demo
  factory InvoiceRequest.mock(int index) {
    final statuses = ['PENDING', 'APPROVED', 'REJECTED', 'DISBURSED'];
    final now = DateTime.now();
    
    return InvoiceRequest(
      id: 'INV$index',
      requestNumber: 'INV/2024/${index.toString().padLeft(5, '0')}',
      invoiceNumber: 'INV/2024/${1000 + index}',
      dealerId: 'DL${index + 1}',
      dealerName: 'Dealer ${index + 1}',
      amount: 500000,
      processingFee: 2500,
      gstAmount: 450,
      netDisbursement: 497050,
      status: statuses[index % 4],
      requestDate: now.subtract(Duration(days: index * 2)),
      approvalDate: statuses[index % 4] == 'APPROVED' || statuses[index % 4] == 'DISBURSED'
          ? now.subtract(Duration(days: index * 2 - 1))
          : null,
      disbursementDate: statuses[index % 4] == 'DISBURSED'
          ? now.subtract(Duration(days: index * 2 - 2))
          : null,
      utrNumber: statuses[index % 4] == 'DISBURSED' 
          ? 'UTR${now.millisecondsSinceEpoch}$index' 
          : null,
      remarks: 'Invoice request processed successfully',
    );
  }
  
  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'DISBURSED':
        return 'Disbursed';
      default:
        return status;
    }
  }
}

class Dealer {
  final String id;
  final String name;
  final String? gstNumber;
  final String? contactNumber;
  final String? address;
  
  Dealer({
    required this.id,
    required this.name,
    this.gstNumber,
    this.contactNumber,
    this.address,
  });
  
  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gstNumber: json['gst_number'],
      contactNumber: json['contact_number'],
      address: json['address'],
    );
  }
  
  // Mock data for demo
  factory Dealer.mock(int index) {
    return Dealer(
      id: 'DL$index',
      name: 'Dealer $index',
      gstNumber: '29AABCU${9600 + index}R1ZN',
      contactNumber: '+91 98765${43210 + index}',
      address: '$index Main Road, Bangalore - ${560001 + index}',
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String dealerName;
  final double invoiceAmount;
  final double approvedAmount;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status;
  
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.dealerName,
    required this.invoiceAmount,
    required this.approvedAmount,
    required this.invoiceDate,
    required this.dueDate,
    required this.status,
  });
  
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      dealerName: json['dealer_name'] ?? '',
      invoiceAmount: (json['invoice_amount'] ?? 0).toDouble(),
      approvedAmount: (json['approved_amount'] ?? 0).toDouble(),
      invoiceDate: DateTime.parse(json['invoice_date'] ?? DateTime.now().toIso8601String()),
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }
  
  // Mock data for demo
  factory Invoice.mock(int index) {
    final now = DateTime.now();
    return Invoice(
      id: 'INV$index',
      invoiceNumber: 'INV/2024/${1000 + index}',
      dealerName: 'Dealer ${index + 1}',
      invoiceAmount: 500000,
      approvedAmount: 450000,
      invoiceDate: now.subtract(Duration(days: 30 - (index * 5))),
      dueDate: now.add(Duration(days: 30 + (index * 10))),
      status: index % 3 == 0 ? 'APPROVED' : 'PENDING',
    );
  }
}

class InvoiceCalculation {
  final double requestedAmount;
  final double processingFeePercentage;
  final double processingFee;
  final double gstPercentage;
  final double gstAmount;
  final double netDisbursement;
  
  InvoiceCalculation({
    required this.requestedAmount,
    required this.processingFeePercentage,
    required this.processingFee,
    required this.gstPercentage,
    required this.gstAmount,
    required this.netDisbursement,
  });
  
  factory InvoiceCalculation.calculate(double amount) {
    const processingFeePercentage = 0.5;
    const gstPercentage = 18.0;
    
    double processingFee = amount * (processingFeePercentage / 100);
    if (processingFee < 250) processingFee = 250;
    
    double gstAmount = processingFee * (gstPercentage / 100);
    double netDisbursement = amount - processingFee - gstAmount;
    
    return InvoiceCalculation(
      requestedAmount: amount,
      processingFeePercentage: processingFeePercentage,
      processingFee: processingFee,
      gstPercentage: gstPercentage,
      gstAmount: gstAmount,
      netDisbursement: netDisbursement,
    );
  }
}

// Invoice Details Model
class InvoiceDetail {
  final String id;
  final String partnerLoanId;
  final String lan;
  final String lender;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceAmount;
  final double remainingInvoiceAmount;
  final int tenureDays;
  final String supplierName;
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;
  final String accountHolderName;
  final double disbursementAmount;
  final double remainingDisbursementAmount;
  final DateTime disbursementDate;
  final DateTime invoiceDueDate;
  final String? disbursementUtr;
  final double roiPercentage;
  final double penalRate;
  final double totalRoiAmount;
  final double emiAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  InvoiceDetail({
    required this.id,
    required this.partnerLoanId,
    required this.lan,
    required this.lender,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceAmount,
    required this.remainingInvoiceAmount,
    required this.tenureDays,
    required this.supplierName,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.accountHolderName,
    required this.disbursementAmount,
    required this.remainingDisbursementAmount,
    required this.disbursementDate,
    required this.invoiceDueDate,
    this.disbursementUtr,
    required this.roiPercentage,
    required this.penalRate,
    required this.totalRoiAmount,
    required this.emiAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      id: json['id']?.toString() ?? '',
      partnerLoanId: json['partner_loan_id'] ?? '',
      lan: json['lan'] ?? '',
      lender: json['lender'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: DateTime.parse(json['invoice_date'] ?? DateTime.now().toIso8601String()),
      invoiceAmount: double.tryParse(json['invoice_amount']?.toString() ?? '0') ?? 0,
      remainingInvoiceAmount: double.tryParse(json['remaining_invoice_amount']?.toString() ?? '0') ?? 0,
      tenureDays: int.tryParse(json['tenure_days']?.toString() ?? '0') ?? 0,
      supplierName: json['supplier_name'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      disbursementAmount: double.tryParse(json['disbursement_amount']?.toString() ?? '0') ?? 0,
      remainingDisbursementAmount: double.tryParse(json['remaining_disbursement_amount']?.toString() ?? '0') ?? 0,
      disbursementDate: DateTime.parse(json['disbursement_date'] ?? DateTime.now().toIso8601String()),
      invoiceDueDate: DateTime.parse(json['invoice_due_date'] ?? DateTime.now().toIso8601String()),
      disbursementUtr: json['disbursement_utr'],
      roiPercentage: double.tryParse(json['roi_percentage']?.toString() ?? '0') ?? 0,
      penalRate: double.tryParse(json['penal_rate']?.toString() ?? '0') ?? 0,
      totalRoiAmount: double.tryParse(json['total_roi_amount']?.toString() ?? '0') ?? 0,
      emiAmount: double.tryParse(json['emi_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'DISBURSED':
        return 'Disbursed';
      case 'CLOSED':
        return 'Closed';
      default:
        return status;
    }
  }
}

class InvoiceDetailsResponse {
  final String lan;
  final String lender;
  final String partnerLoanId;
  final List<InvoiceDetail> invoices;
  
  InvoiceDetailsResponse({
    required this.lan,
    required this.lender,
    required this.partnerLoanId,
    required this.invoices,
  });
  
  factory InvoiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsResponse(
      lan: json['lan'] ?? '',
      lender: json['lender'] ?? '',
      partnerLoanId: json['partnerLoanId'] ?? '',
      invoices: (json['invoices'] as List<dynamic>?)
          ?.map((e) => InvoiceDetail.fromJson(e))
          .toList() ?? [],
    );
  }
}
