import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/invoice_models.dart';
import 'package:intl/intl.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    
    // Load lender types if not loaded
    if (provider.lenderTypes.isEmpty) {
      await provider.loadLenderTypes();
    }
    
    // If we have a selected lender, load invoice details
    if (provider.selectedLender != null && provider.invoicesList.isEmpty) {
      await provider.loadInvoiceDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Lender Dropdown
              _buildLenderDropdown(provider),
              
              // Invoices List
              Expanded(
                child: _buildInvoicesList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLenderDropdown(InvoiceProvider provider) {
    // Get safe selected value that exists in lender types
    final safeSelectedLender = provider.lenderTypes.contains(provider.selectedLender)
        ? provider.selectedLender
        : (provider.lenderTypes.isNotEmpty ? provider.lenderTypes.first : null);

    if (provider.isLoadingLenderTypes) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.lenderTypes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No lenders available'),
      );
    }

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
              value: safeSelectedLender,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: provider.lenderTypes.map((lender) {
                return DropdownMenuItem<String>(
                  value: lender,
                  child: Text(
                    lender,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.selectLender(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(InvoiceProvider provider) {
    if (provider.isLoadingInvoices) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.state == InvoiceState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Failed to load invoices',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadInvoiceDetails(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.invoicesList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadInvoiceDetails(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.invoicesList.length,
        itemBuilder: (context, index) {
          final invoice = provider.invoicesList[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceDetail invoice) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    Color statusColor;
    switch (invoice.status.toUpperCase()) {
      case 'PENDING':
        statusColor = AppColors.warning;
        break;
      case 'APPROVED':
        statusColor = AppColors.info;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
      case 'DISBURSED':
        statusColor = AppColors.success;
        break;
      case 'CLOSED':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.statusDisplay,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      invoice.supplierName,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invoice Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(invoice.invoiceAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Remaining Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(invoice.remainingInvoiceAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Due: ${dateFormat.format(invoice.invoiceDueDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(InvoiceDetail invoice) {
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    provider.selectInvoice(invoice);
    
    context.push('/invoices/${invoice.id}');
  }
}
