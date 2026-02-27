import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/loans_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class LoanDetailScreen extends StatefulWidget {
  final String loanId;
  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<LoansProvider>(context, listen: false);
    
    // Load loans if not already loaded
    if (provider.loans.isEmpty) {
      await provider.loadLoans();
    }
    
    // Now load the EMI schedule with the LAN
    provider.loadEmiSchedule(widget.loanId);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Details')),
      body: Consumer<LoansProvider>(
        builder: (context, provider, child) {
          final loan = provider.selectedLoan;
          if (loan == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loan.loanNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(loan.productType, style: const TextStyle(color: AppColors.textSecondary)),
                        const Divider(height: 24),
                        _buildDetailRow('Sanctioned Amount', currencyFormat.format(loan.sanctionedAmount)),
                        _buildDetailRow('Outstanding', currencyFormat.format(loan.outstandingAmount)),
                        _buildDetailRow('Interest Rate', '${loan.interestRate}%'),
                        _buildDetailRow('Tenure', '${loan.tenureMonths} months'),
                        _buildDetailRow('EMI', currencyFormat.format(loan.emiAmount)),
                        _buildDetailRow('Disbursement Date', dateFormat.format(loan.disbursementDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('EMI Schedule (Till Today)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (provider.emiScheduleResponse.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No EMI schedule data available')),
                    ),
                  )
                else
                  ...provider.emiScheduleResponse.map((emi) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(emi.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              _buildStatusChip(emi.status),
                            ],
                          ),
                          const Divider(height: 16),
                          _buildDetailRow('Invoice Due Date', dateFormat.format(emi.invoiceDueDate)),
                          _buildDetailRow('Disbursement Date', dateFormat.format(emi.disbursementDate)),
                          _buildDetailRow('Total Amount Demand', currencyFormat.format(emi.totalAmountDemand)),
                          _buildDetailRow('Total Principal demand', currencyFormat.format(emi.remainingPrincipal)),
                          _buildDetailRow('Total Interest demand', currencyFormat.format(emi.remainingInterest)),
                          _buildDetailRow('Total Penal Interest', currencyFormat.format(emi.remainingPenalInterest)),
                          _buildDetailRow('Overdue Amount Demand', currencyFormat.format(emi.overdueAmountDemand)),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'PAID-ONETIME':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case 'OVERDUE':
      case 'DUE':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case 'PENDING':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      default:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
