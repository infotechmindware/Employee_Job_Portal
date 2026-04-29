import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedJob = 'All Jobs';
  String _selectedDateRange = 'Last 30 Days';

  final List<String> _jobOptions = ['All Jobs', 'Senior Developer', 'UI/UX Designer'];
  final List<String> _dateOptions = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'];

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
            _buildHeader(isDesktop),
            const SizedBox(height: 24),
            _buildStatsGrid(isDesktop),
            const SizedBox(height: 24),
            _buildMainDashboardGrid(isDesktop),
            const SizedBox(height: 24),
            _buildInterviewOutcomes(isDesktop),
            const SizedBox(height: 24),
            _buildJobPerformance(isDesktop),
            const SizedBox(height: 24),
            _buildCommunicationEffectiveness(isDesktop),
            const SizedBox(height: 24),
            _buildActivityAndSecurity(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Comprehensive insights into your hiring process and performance',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (isDesktop) const Icon(LucideIcons.refreshCcw, size: 20, color: Color(0xFF94A3B8)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown(_selectedJob, _jobOptions, (val) => setState(() => _selectedJob = val!))),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown(_selectedDateRange, _dateOptions, (val) => setState(() => _selectedDateRange = val!))),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF94A3B8)),
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            child: Text(val, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    final stats = [
      {'title': 'Total Jobs', 'value': '0', 'subtitle': '0 active', 'icon': LucideIcons.briefcase, 'color': AppColors.primary},
      {'title': 'Total Applications', 'value': '0', 'subtitle': '0% hire rate', 'icon': LucideIcons.users, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Interviews', 'value': '0', 'subtitle': 'Scheduled today', 'icon': LucideIcons.calendar, 'color': const Color(0xFF3B82F6)},
    ];

    if (!isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat['title'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              Icon(stat['icon'] as IconData, size: 16, color: (stat['color'] as Color).withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(stat['value'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(stat['subtitle'] as String, style: TextStyle(fontSize: 11, color: (stat['color'] as Color))),
        ],
      ),
    );
  }

  Widget _buildMainDashboardGrid(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildFunnelCard(),
          const SizedBox(height: 24),
          _buildTimeToHireCard(),
          const SizedBox(height: 24),
          _buildOfferAcceptanceCard(),
          const SizedBox(height: 24),
          _buildLocationCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildFunnelCard()),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildTimeToHireCard(),
              const SizedBox(height: 24),
              _buildOfferAcceptanceCard(),
              const SizedBox(height: 24),
              _buildLocationCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFunnelCard() {
    return _buildCard(
      title: 'Hiring Funnel',
      child: Column(
        children: [
          const SizedBox(height: 200, child: Center(child: Text('Funnel Chart Placeholder', style: TextStyle(color: Color(0xFF94A3B8))))),
          const Divider(),
          const SizedBox(height: 12),
          _buildFunnelLegend(),
        ],
      ),
    );
  }

  Widget _buildFunnelLegend() {
    final items = [
      {'label': 'Applied', 'value': '0', 'color': Color(0xFF6366F1)},
      {'label': 'Shortlisted', 'value': '0', 'color': Color(0xFF8B5CF6)},
      {'label': 'Interviewed', 'value': '0', 'color': Color(0xFF3B82F6)},
      {'label': 'Offered', 'value': '0', 'color': Color(0xFF10B981)},
      {'label': 'Hired', 'value': '0', 'color': Color(0xFFF59E0B)},
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: items.map((item) => Column(
        children: [
          Text(item['value'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(item['label'] as String, style: TextStyle(fontSize: 10, color: item['color'] as Color, fontWeight: FontWeight.bold)),
        ],
      )).toList(),
    );
  }

  Widget _buildTimeToHireCard() {
    return _buildCard(
      title: 'Time to Hire',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('0 days', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          Text('Posted to Application', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          SizedBox(height: 100, child: Center(child: Text('Chart', style: TextStyle(color: Color(0xFFCBD5E1))))),
        ],
      ),
    );
  }

  Widget _buildOfferAcceptanceCard() {
    return _buildCard(
      title: 'Offer Acceptance',
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text('Offers Made', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 32),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return _buildCard(
      title: 'Applications by Location',
      child: const SizedBox(height: 150, child: Center(child: Text('Location Map Placeholder', style: TextStyle(color: Color(0xFFCBD5E1))))),
    );
  }

  Widget _buildInterviewOutcomes(bool isDesktop) {
    return _buildCard(
      title: 'Interview Outcomes',
      child: const SizedBox(height: 200, child: Center(child: Text('Outcomes Chart Placeholder', style: TextStyle(color: Color(0xFFCBD5E1))))),
    );
  }

  Widget _buildJobPerformance(bool isDesktop) {
    return _buildCard(
      title: 'Job Performance & Quality',
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Text('No job engagement data available', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildCommunicationEffectiveness(bool isDesktop) {
    return _buildCard(
      title: 'Communication Effectiveness',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          _buildCommCard('Messages Sent', '0', const Color(0xFFF0F9FF), const Color(0xFF0EA5E9)),
          _buildCommCard('Replies Received', '0', const Color(0xFFF0FDF4), const Color(0xFF22C55E)),
          _buildCommCard('Avg Response Time', '0 hrs', const Color(0xFFFFFBEB), const Color(0xFFF59E0B)),
          _buildCommCard('Missed Interviews', '0', const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildCommCard(String title, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text)),
        ],
      ),
    );
  }

  Widget _buildActivityAndSecurity(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildActivityOverview(),
          const SizedBox(height: 24),
          _buildSecurityCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildActivityOverview()),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildSecurityCard()),
      ],
    );
  }

  Widget _buildActivityOverview() {
    return _buildCard(
      title: 'Activity Overview',
      child: const SizedBox(height: 250, child: Center(child: Text('Activity Timeline Placeholder', style: TextStyle(color: Color(0xFFCBD5E1))))),
    );
  }

  Widget _buildSecurityCard() {
    return _buildCard(
      title: 'System & Security',
      child: Column(
        children: [
          _buildSecurityItem('Cost Per Hire', '\$0', AppColors.primary),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Security Events', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              Text('0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
