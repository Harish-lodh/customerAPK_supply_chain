import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/invoice_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/invoice_models.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;
  final bool isForApproval;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.isForApproval = false,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _remarksController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Load invoice for approval if specified
    if (widget.isForApproval) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final invoiceId = int.tryParse(widget.invoiceId) ?? 0;
        if (invoiceId > 0) {
          context.read<InvoiceProvider>().getInvoiceForApproval(invoiceId);
        }
      });
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    final invoiceProvider = context.read<InvoiceProvider>();
    final invoiceId = int.tryParse(widget.invoiceId) ?? 0;

    setState(() {
      _isProcessing = true;
    });

    final success = await invoiceProvider.approveInvoice(
      invoiceId,
      _remarksController.text,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice approved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && invoiceProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    final invoiceProvider = context.read<InvoiceProvider>();
    final invoiceId = int.tryParse(widget.invoiceId) ?? 0;

    // Show rejection reason dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectionDialog(),
    );

    if (reason == null || reason.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final success = await invoiceProvider.rejectInvoice(invoiceId, reason);

    setState(() {
      _isProcessing = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice rejected successfully'),
          backgroundColor: AppColors.warning,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && invoiceProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isForApproval ? 'Invoice Approval' : 'Invoice Details'),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          if (provider.state == InvoiceState.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Get the appropriate invoice data
          PendingApprovalInvoice? invoice;
          if (widget.isForApproval) {
            invoice = provider.selectedPendingInvoice;
          } else {
            invoice = provider.selectedPendingInvoice;
          }

          if (invoice == null && !widget.isForApproval) {
            // Show regular invoice detail (legacy)
            return _buildLegacyInvoiceDetail(provider);
          }

          if (invoice == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Invoice not found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return _buildInvoiceDetailContent(invoice, provider);
        },
      ),
      bottomNavigationBar: widget.isForApproval
          ? Consumer<InvoiceProvider>(
              builder: (context, provider, child) {
                final invoice = provider.selectedPendingInvoice;
                if (invoice == null || !invoice.needsApproval) {
                  return const SizedBox.shrink();
                }

                return _buildApprovalButtons();
              },
            )
          : null,
    );
  }

  Widget _buildLegacyInvoiceDetail(InvoiceProvider provider) {
    final invoice = provider.selectedInvoice;

    if (invoice == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No invoice selected',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  invoice.statusDisplay,
                  style: const TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legacy invoice content would go here
          const Text('Invoice details from legacy model'),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailContent(PendingApprovalInvoice invoice, InvoiceProvider provider) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');

    Color statusColor;
    switch (invoice.status.toUpperCase()) {
      case 'PENDING_CUSTOMER_APPROVAL':
        statusColor = AppColors.warning;
        break;
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

    // Helper function to format currency with null handling
    String formatCurrency(double? value) {
      if (value == null || value == 0) return '-';
      return currencyFormat.format(value);
    }

    // Helper function to format date with null handling
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return dateFormat.format(date);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  invoice.statusDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (invoice.needsApproval) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Action Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Invoice Information
          _buildSectionTitle('Invoice Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Invoice Number', invoice.invoiceNumber.isNotEmpty ? invoice.invoiceNumber : '-'),
            _buildDetailRow('Invoice Date', formatDate(invoice.invoiceDate)),
            if (invoice.invoiceDueDate != null)
              _buildDetailRow('Invoice Due Date', formatDate(invoice.invoiceDueDate)),
            if (invoice.description != null && invoice.description!.isNotEmpty)
              _buildDetailRow('Description', invoice.description!),
          ]),
          const SizedBox(height: 24),

          // Amount Details
          _buildSectionTitle('Amount Details'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Invoice Amount', formatCurrency(invoice.invoiceAmount)),
            _buildDetailRow('Disbursement Amount', formatCurrency(invoice.disbursementAmount)),
            if (invoice.disbursedAmount != null)
              _buildDetailRow('Disbursed Amount', formatCurrency(invoice.disbursedAmount)),
          ]),
          const SizedBox(height: 24),

          // Supplier Information
          if (invoice.supplier != null) ...[
            _buildSectionTitle('Supplier Information'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow('Supplier Name', invoice.supplier!.supplierName.isNotEmpty ? invoice.supplier!.supplierName : '-'),
              _buildDetailRow('Supplier Code', invoice.supplier!.supplierCode.isNotEmpty ? invoice.supplier!.supplierCode : '-'),
              if (invoice.supplier!.contactNumber.isNotEmpty)
                _buildDetailRow('Contact Number', invoice.supplier!.contactNumber),
              if (invoice.supplier!.gstNumber != null && invoice.supplier!.gstNumber!.isNotEmpty)
                _buildDetailRow('GST Number', invoice.supplier!.gstNumber!),
              if (invoice.supplier!.address != null && invoice.supplier!.address!.isNotEmpty)
                _buildDetailRow('Address', invoice.supplier!.address!),
            ]),
            const SizedBox(height: 24),
          ],

          // Loan Account Information
          if (invoice.loanAccount != null) ...[
            _buildSectionTitle('Loan Account Information'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow('Lender', invoice.loanAccount!.lender.isNotEmpty ? invoice.loanAccount!.lender : '-'),
              _buildDetailRow('LAN ID', invoice.loanAccount!.lanId.isNotEmpty ? invoice.loanAccount!.lanId : '-'),
              _buildDetailRow('Sanctioned Amount', formatCurrency(invoice.loanAccount!.sanctionedAmount)),
              _buildDetailRow('Disbursed Amount', formatCurrency(invoice.loanAccount!.disbursedAmount)),
              if (invoice.disbursementDate != null)
                _buildDetailRow('Disbursement Date', formatDate(invoice.disbursementDate)),
              if (invoice.disbursementUtr != null && invoice.disbursementUtr!.isNotEmpty)
                _buildDetailRow('Disbursement UTR', invoice.disbursementUtr!),
            ]),
            const SizedBox(height: 24),
          ],

          // Financial Details
          if (invoice.roiPercentage != null || invoice.emiAmount != null) ...[
            _buildSectionTitle('Financial Details'),
            const SizedBox(height: 12),
            _buildDetailCard([
              if (invoice.roiPercentage != null)
                _buildDetailRow('ROI Percentage', '${invoice.roiPercentage}%'),
              if (invoice.roiAmount != null)
                _buildDetailRow('ROI Amount', formatCurrency(invoice.roiAmount)),
              if (invoice.emiAmount != null)
                _buildDetailRow('EMI Amount', formatCurrency(invoice.emiAmount)),
            ]),
            const SizedBox(height: 24),
          ],
          
          // Customer Approval Information (if already processed)
          if (invoice.customerApprovalStatus != null) ...[
            _buildSectionTitle('Customer Approval Information'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow('Approval Status', invoice.customerApprovalStatus ?? '-'),
              _buildDetailRow('Customer Remarks', invoice.customerRemarks ?? '-'),
              if (invoice.customerApprovedAt != null)
                _buildDetailRow('Approved At', formatDate(invoice.customerApprovedAt)),
              if (invoice.rejectionReason != null)
                _buildDetailRow('Rejection Reason', invoice.rejectionReason!),
            ]),
          ],
          
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildApprovalButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessing ? null : _handleReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Approve',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Rejection Dialog Widget
class _RejectionDialog extends StatefulWidget {
  @override
  State<_RejectionDialog> createState() => _RejectionDialogState();
}

class _RejectionDialogState extends State<_RejectionDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Invoice'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for rejection:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Rejection reason is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_reasonController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
