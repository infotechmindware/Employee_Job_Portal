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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 640 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        physics: const ClampingScrollPhysics(), // Prevent stretching
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 32),
            _buildFilters(isDesktop),
            const SizedBox(height: 32),
            _buildMainStats(isDesktop, isTablet),
            const SizedBox(height: 32),
            _buildPrimaryCharts(isDesktop),
            const SizedBox(height: 32),
            _buildSecondaryInsights(isDesktop),
            const SizedBox(height: 32),
            _buildAppWidgets(isDesktop),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitor your hiring health and candidate performance',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (isDesktop)
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown('Job Position', _selectedJob, _jobOptions, (val) => setState(() => _selectedJob = val!)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFilterDropdown('Timeframe', _selectedDateRange, _dateOptions, (val) => setState(() => _selectedDateRange = val!)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
              items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats(bool isDesktop, bool isTablet) {
    final stats = [
      {'title': 'Total Jobs', 'value': '124', 'change': '+12%', 'icon': LucideIcons.briefcase, 'color': const Color(0xFF6366F1)},
      {'title': 'Applications', 'value': '1,482', 'change': '+24%', 'icon': LucideIcons.users, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Interviews', 'value': '86', 'change': '+8%', 'icon': LucideIcons.calendar, 'color': const Color(0xFF3B82F6)},
      {'title': 'Hired', 'value': '42', 'change': '+15%', 'icon': LucideIcons.userCheck, 'color': const Color(0xFF10B981)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 160,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(stat['icon'] as IconData, size: 20, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(stat['change'] as String, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          Text(
            stat['title'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCharts(bool isDesktop) {
    return isDesktop
        ? Row(
            children: [
              Expanded(child: _buildChartCard('Hiring Velocity', _buildFunnelContent())),
              const SizedBox(width: 24),
              Expanded(child: _buildChartCard('Source Distribution', _buildSourcesContent())),
            ],
          )
        : Column(
            children: [
              _buildChartCard('Hiring Velocity', _buildFunnelContent()),
              const SizedBox(height: 24),
              _buildChartCard('Source Distribution', _buildSourcesContent()),
            ],
          );
  }

  Widget _buildSecondaryInsights(bool isDesktop) {
    return isDesktop
        ? Row(
            children: [
              Expanded(child: _buildChartCard('Talent Geography', _buildLocationContent())),
              const SizedBox(width: 24),
              Expanded(child: _buildChartCard('Time to Fill', _buildTimeToHireContent())),
            ],
          )
        : Column(
            children: [
              _buildChartCard('Talent Geography', _buildLocationContent()),
              const SizedBox(height: 24),
              _buildChartCard('Time to Fill', _buildTimeToHireContent()),
            ],
          );
  }

  Widget _buildAppWidgets(bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildChartCard('Communication Widget', _buildCommContent())),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildChartCard('Security Status', _buildSecurityContent())),
            ],
          )
        : Column(
            children: [
              _buildChartCard('Communication Widget', _buildCommContent()),
              const SizedBox(height: 24),
              _buildChartCard('Security Status', _buildSecurityContent()),
            ],
          );
  }

  Widget _buildChartCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const Icon(LucideIcons.arrowUpRight, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildFunnelContent() {
    final data = [
      {'label': 'Applications', 'v': '1.4k', 'p': 1.0, 'c': const Color(0xFF6366F1)},
      {'label': 'Interviewed', 'v': '124', 'p': 0.35, 'c': const Color(0xFF3B82F6)},
      {'label': 'Hired', 'v': '42', 'p': 0.12, 'c': const Color(0xFF10B981)},
    ];

    return Column(
      children: data.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                Text(d['v'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10))),
                FractionallySizedBox(
                  widthFactor: d['p'] as double,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [(d['c'] as Color).withOpacity(0.8), d['c'] as Color]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSourcesContent() {
    final sources = [
      {'name': 'LinkedIn', 'p': '45%', 'c': const Color(0xFF0A66C2)},
      {'name': 'Direct', 'p': '32%', 'c': const Color(0xFF6366F1)},
      {'name': 'Referral', 'p': '23%', 'c': const Color(0xFF10B981)},
    ];

    return Column(
      children: sources.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: s['c'] as Color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(s['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            const Spacer(),
            Text(s['p'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLocationContent() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.globe, size: 32, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text('Data Visualized Globally', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToHireContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTrendStat('Avg Days', '18', LucideIcons.clock, Colors.blue),
        _buildTrendStat('Optimized', '14%', LucideIcons.trendingUp, Colors.green),
      ],
    );
  }

  Widget _buildTrendStat(String label, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 12),
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildCommContent() {
    return Row(
      children: [
        Expanded(child: _buildMiniWidgetStat('Response', '94%', LucideIcons.zap, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildMiniWidgetStat('Velocity', '2.4h', LucideIcons.activity, Colors.blue)),
      ],
    );
  }

  Widget _buildMiniWidgetStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSecurityContent() {
    return Column(
      children: [
        _buildSecurityRow('Firewall', 'Active', Colors.green),
        const SizedBox(height: 10),
        _buildSecurityRow('Backups', 'Secured', Colors.blue),
      ],
    );
  }

  Widget _buildSecurityRow(String label, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
        ),
      ],
    );
  }
}
