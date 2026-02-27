import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/invoice_models.dart';
import 'package:intl/intl.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
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

          return _buildInvoiceDetailContent(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceDetailContent(InvoiceDetail invoice) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Invoice Information
          _buildSectionTitle('Invoice Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Invoice Number', invoice.invoiceNumber),
            _buildDetailRow('Invoice Date', dateFormat.format(invoice.invoiceDate)),
            _buildDetailRow('Invoice Due Date', dateFormat.format(invoice.invoiceDueDate)),
            _buildDetailRow('Tenure Days', '${invoice.tenureDays} days'),
          ]),
          const SizedBox(height: 24),

          // Amount Details
          _buildSectionTitle('Amount Details'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Invoice Amount', currencyFormat.format(invoice.invoiceAmount)),
            _buildDetailRow('Remaining Invoice Amount', currencyFormat.format(invoice.remainingInvoiceAmount)),
            _buildDetailRow('Disbursement Amount', currencyFormat.format(invoice.disbursementAmount)),
            _buildDetailRow('Remaining Disbursement Amount', currencyFormat.format(invoice.remainingDisbursementAmount)),
          ]),
          const SizedBox(height: 24),

          // Supplier Information
          _buildSectionTitle('Supplier Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Supplier Name', invoice.supplierName),
            _buildDetailRow('Bank Name', invoice.bankName),
            _buildDetailRow('Account Holder Name', invoice.accountHolderName),
            _buildDetailRow('Bank Account Number', invoice.bankAccountNumber),
            _buildDetailRow('IFSC Code', invoice.ifscCode),
          ]),
          const SizedBox(height: 24),

          // Loan Information
          _buildSectionTitle('Loan Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('LAN', invoice.lan),
            _buildDetailRow('Lender', invoice.lender),
            _buildDetailRow('Partner Loan ID', invoice.partnerLoanId),
            _buildDetailRow('Disbursement Date', dateFormat.format(invoice.disbursementDate)),
            if (invoice.disbursementUtr != null)
              _buildDetailRow('Disbursement UTR', invoice.disbursementUtr!),
          ]),
          const SizedBox(height: 24),

          // Financial Details
          _buildSectionTitle('Financial Details'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('ROI Percentage', '${invoice.roiPercentage}%'),
            _buildDetailRow('Penal Rate', '${invoice.penalRate}%'),
            _buildDetailRow('Total ROI Amount', currencyFormat.format(invoice.totalRoiAmount)),
            _buildDetailRow('EMI Amount', currencyFormat.format(invoice.emiAmount)),
          ]),
          const SizedBox(height: 24),

          // Metadata
          _buildSectionTitle('Additional Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Created At', dateFormat.format(invoice.createdAt)),
            _buildDetailRow('Updated At', dateFormat.format(invoice.updatedAt)),
          ]),
          const SizedBox(height: 32),
        ],
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
