import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/invoice_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/invoice_models.dart';
import 'invoice_detail_screen.dart';

class PendingApprovalListScreen extends StatefulWidget {
  const PendingApprovalListScreen({super.key});

  @override
  State<PendingApprovalListScreen> createState() => _PendingApprovalListScreenState();
}

class _PendingApprovalListScreenState extends State<PendingApprovalListScreen> {
  @override
  void initState() {
    super.initState();
    // Load pending approval invoices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadPendingApprovalInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPendingApprovals) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.pendingApprovalInvoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending approvals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All invoices have been reviewed',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPendingApprovalInvoices(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingApprovalInvoices.length,
              itemBuilder: (context, index) {
                final invoice = provider.pendingApprovalInvoices[index];
                return _PendingApprovalCard(
                  invoice: invoice,
                  onTap: () => _navigateToDetail(invoice),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(PendingApprovalInvoice invoice) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(
          invoiceId: invoice.id.toString(),
          isForApproval: true,
        ),
      ),
    );

    // Refresh the list if an action was taken
    if (result == true && mounted) {
      context.read<InvoiceProvider>().loadPendingApprovalInvoices();
    }
  }
}

class _PendingApprovalCard extends StatelessWidget {
  final PendingApprovalInvoice invoice;
  final VoidCallback onTap;

  const _PendingApprovalCard({
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.supplierName.isNotEmpty ? invoice.supplierName : '-',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Amount',
                      _formatCurrencyValue(invoice.invoiceAmount),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Disbursement',
                      _formatCurrencyValue(invoice.disbursementAmount),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Due Date',
                      invoice.invoiceDueDate != null 
                          ? dateFormat.format(invoice.invoiceDueDate!)
                          : '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action Required Badge
              if (invoice.needsApproval)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Action Required',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (invoice.status.toUpperCase()) {
      case 'PENDING_CUSTOMER_APPROVAL':
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        text = 'Pending';
        break;
      case 'APPROVED':
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        text = 'Approved';
        break;
      case 'REJECTED':
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        text = 'Rejected';
        break;
      default:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        text = invoice.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Helper function to format currency with null/zero handling
  String _formatCurrencyValue(double value) {
    if (value == 0) return '-';
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(value);
  }
}
