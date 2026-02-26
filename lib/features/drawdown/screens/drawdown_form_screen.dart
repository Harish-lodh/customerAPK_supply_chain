import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/drawdown_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DrawdownFormScreen extends StatefulWidget {
  const DrawdownFormScreen({super.key});

  @override
  State<DrawdownFormScreen> createState() => _DrawdownFormScreenState();
}

class _DrawdownFormScreenState extends State<DrawdownFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedDealerId;
  String? _selectedInvoiceId;

  // Helper method to get safe dealer value
  String? _getSafeDealerValue(DrawdownProvider provider) {
    if (provider.dealers.isEmpty) return null;
    final dealerIds = provider.dealers.map((d) => d.id).toList();
    return dealerIds.contains(_selectedDealerId) ? _selectedDealerId : null;
  }

  // Helper method to get safe invoice value
  String? _getSafeInvoiceValue(DrawdownProvider provider) {
    if (provider.invoices.isEmpty) return null;
    final invoiceIds = provider.invoices.map((i) => i.id).toList();
    return invoiceIds.contains(_selectedInvoiceId) ? _selectedInvoiceId : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DrawdownProvider>(context, listen: false);
      provider.loadDealers();
      provider.loadInvoices();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    Provider.of<DrawdownProvider>(context, listen: false).calculateProcessingFee(amount);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDealerId == null || _selectedInvoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dealer and invoice')),
      );
      return;
    }

    final provider = Provider.of<DrawdownProvider>(context, listen: false);
    final success = await provider.submitDrawdownRequest(
      invoiceId: _selectedInvoiceId!,
      dealerId: _selectedDealerId!,
      amount: double.parse(_amountController.text),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.successMessage ?? 'Request submitted')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Drawdown')),
      body: Consumer<DrawdownProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dealer Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Dealer'),
                    value: _getSafeDealerValue(provider),
                    items: provider.dealers.map((dealer) {
                      return DropdownMenuItem(
                        value: dealer.id,
                        child: Text(dealer.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDealerId = value),
                    validator: (value) => value == null ? 'Please select a dealer' : null,
                  ),
                  const SizedBox(height: 16),

                  // Invoice Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Invoice'),
                    value: _getSafeInvoiceValue(provider),
                    items: provider.invoices.map((invoice) {
                      return DropdownMenuItem(
                        value: invoice.id,
                        child: Text('${invoice.invoiceNumber} - ${currencyFormat.format(invoice.invoiceAmount)}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedInvoiceId = value),
                    validator: (value) => value == null ? 'Please select an invoice' : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Drawdown Amount',
                      prefixText: '₹ ',
                    ),
                    onChanged: (_) => _calculateFee(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter amount';
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) return 'Please enter valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Fee Calculation
                  if (provider.calculation != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fee Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildFeeRow('Requested Amount', currencyFormat.format(provider.calculation!.requestedAmount)),
                            _buildFeeRow('Processing Fee (${provider.calculation!.processingFeePercentage}%)', currencyFormat.format(provider.calculation!.processingFee)),
                            _buildFeeRow('GST (${provider.calculation!.gstPercentage}%)', currencyFormat.format(provider.calculation!.gstAmount)),
                            const Divider(),
                            _buildFeeRow('Net Disbursement', currencyFormat.format(provider.calculation!.netDisbursement), isBold: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Submit Button
                  ElevatedButton(
                    onPressed: provider.state == DrawdownState.submitting ? null : _submit,
                    child: provider.state == DrawdownState.submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Request'),
                  ),

                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
