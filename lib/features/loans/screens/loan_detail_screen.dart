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
      final provider = Provider.of<LoansProvider>(context, listen: false);
      provider.loadLoans();
      provider.loadEmiSchedule(widget.loanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
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
                const Text('EMI Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...loan.emiSchedule.map((emi) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: emi.status == 'PAID' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                      child: Icon(emi.status == 'PAID' ? Icons.check : Icons.schedule, color: emi.status == 'PAID' ? AppColors.success : AppColors.warning),
                    ),
                    title: Text('EMI ${emi.emiNumber}'),
                    subtitle: Text(dateFormat.format(emi.dueDate)),
                    trailing: Text(currencyFormat.format(emi.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
