import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.state == ProfileState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final company = provider.companyProfile;
          final bank = provider.bankDetails;
          final support = provider.supportContact;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Profile
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Company Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        if (company != null) ...[
                          _buildProfileRow('Company Name', company.companyName),
                          _buildProfileRow('Email', company.email),
                          _buildProfileRow('Mobile', company.mobileNumber),
                          _buildProfileRow('PAN', company.panNumber ?? 'N/A'),
                          _buildProfileRow('GST', company.gstNumber ?? 'N/A'),
                          _buildProfileRow('Address', '${company.address ?? ''}, ${company.city ?? ''}, ${company.state ?? ''}'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bank Details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bank Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        if (bank != null) ...[
                          _buildProfileRow('Bank Name', bank.bankName),
                          _buildProfileRow('Branch', bank.branchName),
                          _buildProfileRow('Account Number', bank.maskedAccountNumber),
                          _buildProfileRow('IFSC Code', bank.ifscCode),
                          _buildProfileRow('Account Type', bank.accountType),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Support Contact
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        if (support != null) ...[
                          _buildProfileRow('Email', support.email),
                          _buildProfileRow('Phone', support.phone),
                          if (support.whatsapp != null) _buildProfileRow('WhatsApp', support.whatsapp!),
                          _buildProfileRow('Working Hours', support.workingHours ?? 'N/A'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
