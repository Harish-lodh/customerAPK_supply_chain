import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/drawdown_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/drawdown_models.dart';
import 'package:intl/intl.dart';

class DrawdownListScreen extends StatefulWidget {
  const DrawdownListScreen({super.key});

  @override
  State<DrawdownListScreen> createState() => _DrawdownListScreenState();
}

class _DrawdownListScreenState extends State<DrawdownListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DrawdownProvider>(context, listen: false).loadDrawdownRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawdown Requests'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/drawdown/apply'),
        icon: const Icon(Icons.add),
        label: const Text('Apply Drawdown'),
      ),
      body: Consumer<DrawdownProvider>(
        builder: (context, provider, child) {
          if (provider.state == DrawdownState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.drawdownRequests.isEmpty) {
            return const Center(child: Text('No drawdown requests'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.drawdownRequests.length,
              itemBuilder: (context, index) {
                final request = provider.drawdownRequests[index];
                return _buildDrawdownCard(request);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawdownCard(DrawdownRequest request) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    Color statusColor;
    switch (request.status) {
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
      default:
        statusColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.requestNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusDisplay,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Amount', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(currencyFormat.format(request.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Net Disbursement', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(currencyFormat.format(request.netDisbursement), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Requested on ${dateFormat.format(request.requestDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
