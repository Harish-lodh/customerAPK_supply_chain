import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: March 2026',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'We, Fintree Finance Pvt. Ltd., are the sole owners of the information collected on our website. We acknowledge and accept that the personal details that you impart to us are to be kept in strict confidentiality. We shall use this information only in a manner beneficial to our customers. We consider our relationship with you as invaluable and strive to respect and safeguard your right to privacy.',
            ),
            _buildSection(
              'Confidentiality',
              'We shall protect the personal details received from you with the same degree of care—no less than a reasonable degree—to prevent unauthorized use, dissemination, or publication, just as we protect our own confidential information.',
            ),
            _buildSection(
              'Information We Collect',
              'The information we collect is limited to what you provide via applications or web forms, including name, business name, contact details, and business location. This data helps us understand your needs and provide excellent customer service, maintain internal records, and improve our products, services, and satisfaction.',
            ),
            _buildSection(
              'Security',
              'We do not compromise on security and take your privacy seriously. We implement various security measures to prevent unauthorized access and ensure the safety of your personal data. Your information will be retained for a minimum of one year or as statutorily required.',
            ),
            _buildSection(
              'Use of Information',
              'Your personal information will help us improve our services and inform you about new offerings or updates that may interest you. It will only be used in the appropriate context and to fulfill your requests and obligations.',
            ),
            _buildSection(
              'Data Collection',
              'We collect only necessary personal data required for administering our services effectively and complying with Indian regulations. To enhance service quality, we may combine your data submitted through various channels.',
            ),
            _buildSection(
              'Data Sharing',
              'Under specific circumstances, we may share your data with trusted third parties to add value to our services or when required by governmental or regulatory authorities. All such data is secured on protected sections of our website.',
            ),
            _buildSection(
              'External Links',
              'While we may offer links to external websites, we do not control their privacy practices. We advise you to review the privacy statements of any linked sites before sharing information.',
            ),
            _buildSection(
              'Data Accuracy',
              'To ensure better service, it is important that your personal information with us remains updated and accurate.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
