import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 32),
            _buildTopStats(isDesktop),
            const SizedBox(height: 32),
            _buildMainContent(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage your subscriptions, usage, and payments',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTopStats(bool isDesktop) {
    final stats = [
      {
        'title': 'Current Plan',
        'value': 'Free',
        'subtitle': 'Renewal: —',
        'icon': LucideIcons.layers,
        'color': const Color(0xFF6366F1),
        'hasAction': true,
      },
      {
        'title': 'Balance Due',
        'value': '₹0.00',
        'subtitle': 'No pending payments',
        'icon': LucideIcons.wallet,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Usage Limits',
        'value': '0%',
        'subtitle': 'Contacts: 0/0',
        'icon': LucideIcons.barChart2,
        'color': const Color(0xFFF59E0B),
      },
    ];

    if (!isDesktop) {
      return SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: stats.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildInfoCard(stats[index], 240),
          ),
        ),
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildInfoCard(stat, null),
        ),
      )).toList(),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> stat, double? width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat['title'] as String,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              Icon(stat['icon'] as IconData, size: 16, color: stat['color'] as Color),
            ],
          ),
          const Spacer(),
          Text(
            stat['value'] as String,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: stat['color'] as Color),
          ),
          const SizedBox(height: 4),
          Text(
            stat['subtitle'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildRecentTransactions(),
          const SizedBox(height: 24),
          _buildAlerts(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildRecentTransactions()),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildAlerts()),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.receipt, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.history, size: 48, color: const Color(0xFFCBD5E1).withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  "No payment history found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Get started by choosing a premium plan for your business.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Upgrade Now',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('View all invoices', LucideIcons.fileText),
              _buildActionButton('View all transactions', LucideIcons.list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        _buildAlertItem(
          'Payment failed last time',
          'Retry',
          const Color(0xFFFEF2F2),
          const Color(0xFFEF4444),
          LucideIcons.alertCircle,
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          'No valid payment method',
          'Add',
          const Color(0xFFFFFBEB),
          const Color(0xFFF59E0B),
          LucideIcons.creditCard,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 16, color: const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                const Text(
                  'Update Billing Info',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String text, String? action, Color bg, Color textCol, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textCol.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textCol),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textCol, fontWeight: FontWeight.w600),
            ),
          ),
          if (action != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textCol.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                action,
                style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
