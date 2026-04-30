import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(),
            const SizedBox(height: 40),
            _buildStatGrid(isDesktop, isTablet),
            const SizedBox(height: 40),
            _buildMainContent(isDesktop),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Welcome back! Here is a summary of your hiring funnel.',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: const Icon(LucideIcons.calendar, size: 20, color: Color(0xFF6366F1)),
        ),
      ],
    );
  }

  Widget _buildStatGrid(bool isDesktop, bool isTablet) {
    final stats = [
      {'title': 'Total Jobs', 'value': '124', 'change': '+12.5%', 'icon': LucideIcons.briefcase, 'color': const Color(0xFF6366F1)},
      {'title': 'Applications', 'value': '2,842', 'change': '+28.4%', 'icon': LucideIcons.users, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Interviews', 'value': '156', 'change': '+4.2%', 'icon': LucideIcons.calendarCheck, 'color': const Color(0xFF3B82F6)},
      {'title': 'Hired Candidates', 'value': '48', 'change': '+18.1%', 'icon': LucideIcons.userCheck, 'color': const Color(0xFF10B981)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 180,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(stat['icon'] as IconData, size: 22, color: color),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    stat['change'] as String,
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value'] as String,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stat['title'] as String,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isDesktop ? 2 : 1,
          child: Column(
            children: [
              _buildChartSection(),
              const SizedBox(height: 40),
              _buildJobsSection(),
            ],
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(width: 32),
          Expanded(child: _buildActivitySection()),
        ],
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hiring Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Icon(LucideIcons.maximize2, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(2, 4), FlSpot(4, 3.5), FlSpot(6, 6), FlSpot(8, 4), FlSpot(10, 7), FlSpot(12, 6.5),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    barWidth: 6,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6366F1).withOpacity(0.2), const Color(0xFF6366F1).withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Active Opportunities',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
          ),
        ),
        const SizedBox(height: 24),
        _buildModernJobItem('Lead Product Designer', '8 applicants', 'Active', const Color(0xFF10B981)),
        _buildModernJobItem('Senior Backend Engineer', '24 applicants', 'Active', const Color(0xFF10B981)),
        _buildModernJobItem('Marketing Manager', '15 applicants', 'Closed', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildModernJobItem(String title, String applicants, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
            child: Icon(LucideIcons.briefcase, size: 24, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(applicants, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Stream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 32),
          _buildModernActivityItem('Application received', 'Alex Rivera • Frontend Dev', 'Just now', LucideIcons.userPlus, const Color(0xFF6366F1)),
          _buildModernActivityItem('Interview started', 'Meeting room • Room A1', '12m ago', LucideIcons.video, const Color(0xFF10B981)),
          _buildModernActivityItem('New message', 'Client • Project Update', '45m ago', LucideIcons.mail, const Color(0xFF3B82F6)),
          _buildModernActivityItem('Report generated', 'Weekly Hiring Health', '2h ago', LucideIcons.fileText, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildModernActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
