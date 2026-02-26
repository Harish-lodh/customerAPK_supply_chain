import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../providers/loans_provider.dart';
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
      _initializeData();
    });
  }
  
  Future<void> _initializeData() async {
    final transactionsProvider = Provider.of<TransactionsProvider>(context, listen: false);
    final loansProvider = Provider.of<LoansProvider>(context, listen: false);
    
    // Load lender types
    await transactionsProvider.loadLenderTypes();
    
    // Initialize LANs (hidden from UI)
    if (loansProvider.loans.isEmpty) {
      await loansProvider.loadLoans();
    }
    await transactionsProvider.initializeLans(loansProvider.loans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Lender Type Dropdown
              if (provider.lenderTypes.isNotEmpty) _buildLenderTypeDropdown(provider),
              
              // Transactions List
              Expanded(
                child: _buildTransactionsList(provider),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLenderTypeDropdown(TransactionsProvider provider) {
    // Get safe selected value that exists in lender types
    final safeSelectedLenderType = provider.lenderTypes.contains(provider.selectedLenderType) ? provider.selectedLenderType : (provider.lenderTypes.isNotEmpty ? provider.lenderTypes.first : null);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Lender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: safeSelectedLenderType,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: provider.lenderTypes.map((lenderType) {
                return DropdownMenuItem<String>(
                  value: lenderType,
                  child: Text(
                    lenderType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.selectLenderType(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsList(TransactionsProvider provider) {
    if (provider.state == TransactionsState.loading && provider.collectionTransactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.state == TransactionsState.error && provider.collectionTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Failed to load transactions',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (provider.collectionTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.collectionTransactions.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.collectionTransactions.length) {
            provider.loadMore();
            return const Center(child: CircularProgressIndicator());
          }
          return _buildCollectionTransactionCard(provider.collectionTransactions[index]);
        },
      ),
    );
  }
  
  Widget _buildCollectionTransactionCard(CollectionTransaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showAllocationDetails(transaction),
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withOpacity(0.1),
          child: const Icon(Icons.arrow_downward, color: AppColors.success),
        ),
        title: const Text(
          'Collection',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.collectionUtr != null)
              Text(
                'UTR: ${transaction.collectionUtr}',
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              dateFormat.format(transaction.collectionDate),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Text(
          '+${currencyFormat.format(transaction.collectionAmount)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
  
  void _showAllocationDetails(CollectionTransaction transaction) async {
    final provider = Provider.of<TransactionsProvider>(context, listen: false);
    final selectedLan = provider.selectedLan;
    
    if (selectedLan == null || transaction.collectionUtr == null) {
      return;
    }
    
    // Show loading indicator
    provider.getTransactionDetail(selectedLan, transaction.collectionUtr!);
    
    // Wait for the detail to load
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Show details in bottom sheet if loaded
    if (mounted && provider.transactionDetail != null) {
      _showAllocationBottomSheet(provider);
    }
  }
  
  void _showAllocationBottomSheet(TransactionsProvider provider) {
    final detail = provider.transactionDetail!;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('LAN: ${detail.lan}', style: const TextStyle(color: AppColors.textSecondary)),
            Text('UTR: ${detail.collectionUtr}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            
            // Total Collected
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Collected', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    currencyFormat.format(detail.totalCollected),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Allocation Breakup
            const Text('Allocation Breakup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAllocationRow('Principal', detail.allocationBreakup.allocatedPrincipal, currencyFormat),
            _buildAllocationRow('Interest', detail.allocationBreakup.allocatedInterest, currencyFormat),
            _buildAllocationRow('Penal Interest', detail.allocationBreakup.allocatedPenalInterest, currencyFormat),
            _buildAllocationRow('Excess Payment', detail.allocationBreakup.excessPayment, currencyFormat),
            const Divider(height: 32),
            
            // Invoice-wise Allocation
            const Text('Invoice-wise Allocation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...detail.invoiceWiseAllocation.map((invoice) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildAllocationRow('Principal', invoice.allocatedPrincipal, currencyFormat),
                  _buildAllocationRow('Interest', invoice.allocatedInterest, currencyFormat),
                  _buildAllocationRow('Penal Interest', invoice.allocatedPenalInterest, currencyFormat),
                ],
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAllocationRow(String label, double amount, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(currencyFormat.format(amount)),
        ],
      ),
    );
  }
}
