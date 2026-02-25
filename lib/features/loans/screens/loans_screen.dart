import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/loans_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/loan_models.dart';
import 'package:intl/intl.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoansProvider>(context, listen: false).loadLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Loans')),
      body: Consumer<LoansProvider>(
        builder: (context, provider, child) {
          if (provider.state == LoansState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.loans.length,
              itemBuilder: (context, index) {
                final loan = provider.loans[index];
                return _buildLoanCard(loan);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/loans/${loan.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loan.loanNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(loan.status, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(loan.productType, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Sanction Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(currencyFormat.format(loan.sanctionedAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Available', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(currencyFormat.format(loan.outstandingAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Rate', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text('${loan.interestRate}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tenure', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text('${loan.tenureMonths} Months', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Utilized', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(currencyFormat.format(loan.utilizedAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
