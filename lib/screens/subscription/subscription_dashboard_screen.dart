import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SubscriptionDashboardScreen extends StatelessWidget {
  const SubscriptionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 48 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildMainContent(context)),
                  const SizedBox(width: 32),
                  Expanded(child: _buildSideContent()),
                ],
              )
            else
              Column(
                children: [
                  _buildMainContent(context),
                  const SizedBox(height: 32),
                  _buildSideContent(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscription Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your plan, billing, and usage metrics',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Change Plan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        _buildCurrentPlanCard(),
        const SizedBox(height: 32),
        _buildUsageSection(),
      ],
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Text('Active', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Premium Plan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          _buildInfoRow('Billing Cycle', 'Quarterly'),
          const SizedBox(height: 16),
          _buildInfoRow('Valid Until', 'Oct 24, 2026'),
          const SizedBox(height: 16),
          _buildInfoRow('Next Payment', '₹2,300 • Oct 24, 2026'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUsageSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resource Usage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 32),
          _buildUsageItem('Active Job Posts', '8', '15', 8 / 15),
          const SizedBox(height: 24),
          _buildUsageItem('Candidates Contacted', '452', '1000', 452 / 1000),
          const SizedBox(height: 24),
          _buildUsageItem('Team Members', '3', '5', 3 / 5),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, String used, String total, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: used, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
                  TextSpan(text: ' / $total', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
        ),
      ],
    );
  }

  Widget _buildSideContent() {
    return Column(
      children: [
        _buildSideCard('Plan Features', [
          'Unlimited Job Listings',
          'AI Matching Technology',
          'Priority Support',
          'Advanced Analytics',
          'Custom Branding',
        ]),
        const SizedBox(height: 24),
        _buildSideCard('Payment History', [
          'INV-2024-001 • ₹2,300 • Paid',
          'INV-2024-002 • ₹2,300 • Paid',
          'INV-2023-098 • ₹2,300 • Paid',
        ]),
      ],
    );
  }

  Widget _buildSideCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
