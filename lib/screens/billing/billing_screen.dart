import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Billing Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            _buildTopStats(isDesktop),
            const SizedBox(height: 24),
            _buildMainGrid(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStats(bool isDesktop) {
    final stats = [
      {
        'title': 'Current Plan',
        'value': 'Free',
        'subtitle': 'Renewal: —',
        'action': 'Manage plan',
        'isButton': true,
      },
      {
        'title': 'Balance Due',
        'value': '₹0.00',
        'subtitle': 'View invoices',
        'isLink': true,
      },
      {
        'title': 'Upcoming Payment',
        'value': '₹—',
        'subtitle': 'On —',
      },
      {
        'title': 'Last Payment',
        'value': '₹—',
        'subtitle': '—',
      },
    ];

    if (!isDesktop) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stats.map((stat) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildInfoCard(stat, 200),
          )).toList(),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat['title'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            stat['value'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          if (stat['isLink'] == true)
            InkWell(
              onTap: () {},
              child: Text(
                stat['subtitle'] as String,
                style: const TextStyle(fontSize: 12, color: AppColors.primary, decoration: TextDecoration.underline),
              ),
            )
          else
            Text(
              stat['subtitle'] as String,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          if (stat['isButton'] == true) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(stat['action'] as String, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainGrid(bool isDesktop) {
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 32),
          const Text(
            "You don't have any payments yet.",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          InkWell(
            onTap: () {},
            child: const Text(
              'Buy a plan',
              style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildTransactionButton('View all invoices'),
              const SizedBox(width: 12),
              _buildTransactionButton('View all transactions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alerts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        _buildAlertItem(
          'Payment failed last time',
          'Retry payment',
          const Color(0xFFFFFBEB),
          const Color(0xFFB45309),
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          'No valid payment method',
          'Add card',
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          'Quota left Contacts: 0/0',
          null,
          const Color(0xFFF0F9FF),
          const Color(0xFF0369A1),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Update billing information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String text, String? action, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textCol, fontWeight: FontWeight.w500),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: () {},
              child: Text(
                action,
                style: TextStyle(fontSize: 13, color: textCol, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ),
        ],
      ),
    );
  }
}
