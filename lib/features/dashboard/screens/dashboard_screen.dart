import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/dashboard_models.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.state == DashboardState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.state == DashboardState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dashboardProvider.errorMessage ?? 'Error loading dashboard'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dashboardProvider.loadDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dashboard = dashboardProvider.dashboard;
          if (dashboard == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Limit Card
                  _buildLimitCard(dashboard),
                  const SizedBox(height: 16),
                  
                  // Quick Stats
                  _buildQuickStats(dashboard),
                  const SizedBox(height: 24),
                  
                  // Total Loans and Disbursed
                  _buildLoanSummary(dashboard),
                  const SizedBox(height: 24),
                  
                  // Recent Repayments
                  if (dashboard.recentRepayments.isNotEmpty) ...[
                    Text(
                      'Recent Repayments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildRecentRepayments(dashboard),
                    const SizedBox(height: 24),
                  ],
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(dashboard),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLimitCard(Dashboard dashboard) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit Limit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dashboard.utilizationPercentage.toStringAsFixed(1)}% Utilized',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pie Chart
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.primaryBlue,
                      value: dashboard.utilizedAmount,
                      title: '',
                      radius: 30,
                    ),
                    PieChartSectionData(
                      color: AppColors.chartGreen,
                      value: dashboard.availableLimit,
                      title: '',
                      radius: 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Utilized', currencyFormat.format(dashboard.utilizedAmount), AppColors.primaryBlue),
                _buildLegendItem('Available', currencyFormat.format(dashboard.availableLimit), AppColors.chartGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Dashboard dashboard) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Loans',
            dashboard.activeLoansCount.toString(),
            Icons.account_balance,
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Overdue',
            currencyFormat.format(dashboard.overdueAmount),
            Icons.warning_amber,
            dashboard.overdueAmount > 0 ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Next EMI',
            dashboard.nextEmiDate != null 
                ? dateFormat.format(dashboard.nextEmiDate!)
                : 'N/A',
            Icons.calendar_today,
            AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanSummary(Dashboard dashboard) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Loans',
                    dashboard.totalLoans.toString(),
                    Icons.assignment,
                    AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Disbursed',
                    currencyFormat.format(dashboard.totalDisbursed),
                    Icons.payments,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Outstanding',
                    currencyFormat.format(dashboard.totalOutstanding),
                    Icons.account_balance_wallet,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentRepayments(Dashboard dashboard) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dashboard.recentRepayments.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final repayment = dashboard.recentRepayments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(0.1),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            title: Text(
              'LAN: ${repayment.lan}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              dateFormat.format(repayment.collectionDate),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              currencyFormat.format(repayment.collectionAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(Dashboard dashboard) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          'View Invoices',
          Icons.receipt_long,
          () => context.go('/invoices'),
        ),
        _buildActionCard(
          'View Statement',
          Icons.description,
          () => context.go('/transactions'),
        ),
        _buildActionCard(
          'Repay Now',
          Icons.payment,
          () => context.go('/loans'),
        ),
        _buildActionCard(
          'Foreclosure',
          Icons.cancel_outlined,
          () => context.go('/loans'),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
