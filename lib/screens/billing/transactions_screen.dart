import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
              'Transactions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            _buildStatsCards(isDesktop),
            const SizedBox(height: 24),
            _buildFilters(isDesktop),
            const SizedBox(height: 24),
            _buildTransactionsTable(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    final stats = [
      {'title': 'Total Transactions', 'value': '0', 'color': Color(0xFF64748B)},
      {'title': 'Total Paid', 'value': '₹0.00', 'color': Color(0xFF10B981)},
      {'title': 'Pending Amount', 'value': '₹0.00', 'color': Color(0xFFF59E0B)},
      {'title': 'Failed Transactions', 'value': '0', 'color': Color(0xFFEF4444)},
    ];

    if (!isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) => _buildStatCard(stats[index]),
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStatCard(stat),
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat['title'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(stat['value'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: stat['color'] as Color)),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          _buildFilterItem('From Date', 'dd-mm-yyyy', 150),
          _buildFilterItem('To Date', 'dd-mm-yyyy', 150),
          _buildDropdownFilter('Transaction Type', 'ALL', 150),
          _buildDropdownFilter('Status', 'All', 150),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Filter'),
          ),
          TextButton(onPressed: () {}, child: const Text('Reset Filters', style: TextStyle(color: Color(0xFF64748B)))),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String hint, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTable(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Column(
        children: [
          SizedBox(height: 100, child: Center(child: Text('No transactions found for selected filters', style: TextStyle(color: Color(0xFF94A3B8))))),
        ],
      ),
    );
  }
}
