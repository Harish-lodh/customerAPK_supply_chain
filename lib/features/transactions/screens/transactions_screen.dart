import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/transaction_models.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionsProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionsProvider>(
        builder: (context, provider, child) {
          if (provider.state == TransactionsState.loading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transactions.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.transactions.length) {
                  provider.loadMore();
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTransactionCard(provider.transactions[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    final isCredit = transaction.isCredit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? AppColors.success : AppColors.error),
        ),
        title: Text(transaction.typeDisplay, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.loanNumber ?? '', style: const TextStyle(fontSize: 12)),
            Text(dateFormat.format(transaction.transactionDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? AppColors.success : AppColors.error,
          ),
        ),
      ),
    );
  }
}
