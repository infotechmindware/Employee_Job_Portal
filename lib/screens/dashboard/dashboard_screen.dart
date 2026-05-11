import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int? _activeStatIndex;
  int? _activeActivityIndex;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardDataProvider.future),
        color: const Color(0xFF6366F1),
        child: dashboardAsync.when(
          loading: () => _buildSkeletonLoading(isDesktop, isTablet),
          error: (err, stack) => _buildErrorState(err),
          data: (data) => _buildDashboardContent(data, isDesktop, isTablet),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(width: 200, height: 32),
          const SizedBox(height: 8),
          _buildSkeletonBox(width: 300, height: 16),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: 140,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _buildSkeletonBox(borderRadius: 24),
          ),
          const SizedBox(height: 32),
          _buildSkeletonBox(height: 400, borderRadius: 24),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({double? width, double? height, double borderRadius = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[100],
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Failed to load dashboard data', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardDataProvider),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(Map<String, dynamic> data, bool isDesktop, bool isTablet) {
    final stats = _parseStats(data);
    final activities = data['recent_activities'] as List? ?? [];
    final recentJobs = data['recent_jobs'] as List? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernHeader(),
          const SizedBox(height: 32),
          _buildStatGrid(stats, isDesktop, isTablet),
          const SizedBox(height: 32),
          
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildRecentJobsSection(recentJobs),
                      const SizedBox(height: 32),
                      _buildChartSection(data, isDesktop, isTablet),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildQuickActionsGrid(),
                      const SizedBox(height: 32),
                      _buildActivitySection(activities),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildQuickActionsGrid(),
                const SizedBox(height: 32),
                _buildRecentJobsSection(recentJobs),
                const SizedBox(height: 32),
                _buildChartSection(data, isDesktop, isTablet),
                const SizedBox(height: 32),
                _buildActivitySection(activities),
              ],
            ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseStats(Map<String, dynamic> data) {
    return [
      {
        'title': 'Active Jobs', 
        'value': (data['active_jobs'] ?? '0').toString(), 
        'icon': LucideIcons.briefcase, 
        'color': const Color(0xFF3B82F6),
        'onTap': () => ref.read(navigationProvider.notifier).setIndex(1),
      },
      {
        'title': 'Total Applications', 
        'value': (data['total_applications'] ?? '0').toString(), 
        'icon': LucideIcons.fileText, 
        'color': const Color(0xFF6366F1),
        'onTap': () => ref.read(navigationProvider.notifier).setIndex(2, appTabIndex: 0),
      },
      {
        'title': 'New Applications', 
        'value': (data['new_applications'] ?? '0').toString(), 
        'icon': LucideIcons.userPlus, 
        'color': const Color(0xFF8B5CF6),
        'onTap': () => ref.read(navigationProvider.notifier).setIndex(2, appTabIndex: 1),
      },
      {
        'title': 'Interviews Scheduled', 
        'value': (data['interviews_scheduled'] ?? '0').toString(), 
        'icon': LucideIcons.calendar, 
        'color': const Color(0xFF10B981),
        'onTap': () => ref.read(navigationProvider.notifier).setIndex(3),
      },
    ];
  }

  Widget _buildModernHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1.0),
        ),
        SizedBox(height: 6),
        Text(
          'Welcome back! Here is a summary of your platform activity.',
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatGrid(List<Map<String, dynamic>> stats, bool isDesktop, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 140,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _StatCard(
          stat: stats[index],
          isActive: _activeStatIndex == index,
          onTap: stats[index]['onTap'],
        );
      },
    );
  }

  Widget _buildRecentJobsSection(List<dynamic> jobs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.briefcase, size: 20, color: Color(0xFF6366F1)),
                  SizedBox(width: 12),
                  Text('Recent Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              TextButton(
                onPressed: () => ref.read(navigationProvider.notifier).setIndex(1),
                child: const Text('View all', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (jobs.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No jobs posted yet', style: TextStyle(color: Colors.grey))))
          else
            ...jobs.map((j) => _buildJobItem(j)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    final status = job['status']?.toString().toLowerCase() ?? 'published';
    final statusColor = status == 'published' ? const Color(0xFF10B981) : Colors.grey;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['title'] ?? 'Job Title', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const WidgetSpan(child: Icon(LucideIcons.users, size: 14, color: Colors.grey), alignment: PlaceholderAlignment.middle),
                          const WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(text: '${job['applications_count'] ?? 0} applications'),
                        ],
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const WidgetSpan(child: Icon(LucideIcons.mapPin, size: 14, color: Colors.grey), alignment: PlaceholderAlignment.middle),
                          const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(text: job['location'] ?? 'Remote'),
                        ],
                      ),
                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard('Post a Job', LucideIcons.plus, const Color(0xFF6366F1), () => ref.read(navigationProvider.notifier).setIndex(1)),
        _buildActionCard('View Applications', LucideIcons.users, const Color(0xFFF43F5E), () => ref.read(navigationProvider.notifier).setIndex(2)),
        _buildActionCard('Schedule Interview', LucideIcons.calendar, const Color(0xFF8B5CF6), () => ref.read(navigationProvider.notifier).setIndex(3)),
        _buildActionCard('Search Candidates', LucideIcons.search, const Color(0xFFF59E0B), () => ref.read(navigationProvider.notifier).setIndex(2)),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(Map<String, dynamic> data, bool isDesktop, bool isTablet) {
    final chartData = data['analytics_data'] as List? ?? [];
    final total = data['total_applications'] ?? 0;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Application Trends', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                    Text('Application volume over the last 30 days', style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$total', style: TextStyle(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                  const Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: isSmallScreen ? 1.5 : 2.5,
            child: SizedBox(
              height: isDesktop ? 320 : (isTablet ? 280 : 240),
              width: double.infinity,
              child: chartData.isEmpty 
                ? const Center(child: Text('No data available')) 
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: _calculateMaxY(chartData),
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100]!, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: isSmallScreen ? 10 : 5, 
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 || value.toInt() >= chartData.length) return const SizedBox();
                              final dateStr = chartData[value.toInt()]['date']?.toString() ?? '';
                              if (dateStr.isEmpty) return const SizedBox();
                              try {
                                final date = DateTime.parse(dateStr);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat(isSmallScreen ? 'MM/dd' : 'MMM dd').format(date), 
                                    style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w600),
                                  ),
                                );
                              } catch (_) {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isSmallScreen ? 35 : 45,
                            interval: _calculateYInterval(chartData),
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(), 
                                style: TextStyle(color: Colors.grey, fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => const Color(0xFF0F172A),
                          tooltipBorderRadius: BorderRadius.circular(8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final dateStr = chartData[spot.x.toInt()]['date']?.toString() ?? '';
                              final date = DateTime.parse(dateStr);
                              return LineTooltipItem(
                                '${DateFormat('MMM dd, yyyy').format(date)}\n',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: '${spot.y.toInt()} Applications',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 11),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.asMap().entries.map((e) {
                            final val = e.value['count'] ?? e.value['value'] ?? 0;
                            return FlSpot(e.key.toDouble(), (val as num).toDouble());
                          }).toList(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: spot.y > 0 ? 1 : 0,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: const Color(0xFF6366F1),
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [const Color(0xFF6366F1).withOpacity(0.2), const Color(0xFF8B5CF6).withOpacity(0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(List<dynamic> activities) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          if (activities.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length > 8 ? 8 : activities.length,
              itemBuilder: (context, index) {
                final a = activities[index];
                return _ActivityCard(
                  title: (a['candidate_name'] ?? a['title'] ?? 'System').toString(),
                  subtitle: (a['message'] ?? a['subtitle'] ?? '').toString(),
                  time: _formatTimestamp(a['created_at'] ?? a['time']),
                  type: (a['type'] ?? 'notification').toString(),
                  onTap: () {},
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) return 'Just now';
    try {
      DateTime dt;
      if (timestamp is String) {
        dt = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else if (timestamp is DateTime) {
        dt = timestamp;
      } else {
        return timestamp.toString();
      }
      
      // Use web dashboard format: May 10, 14:34
      return DateFormat('MMM dd, HH:mm').format(dt);
    } catch (_) {
      return timestamp.toString();
    }
  }

  double _calculateMaxY(List<dynamic> chartData) {
    if (chartData.isEmpty) return 10;
    double maxVal = 0;
    for (var entry in chartData) {
      final val = (entry['count'] ?? entry['value'] ?? 0) as num;
      if (val > maxVal) maxVal = val.toDouble();
    }
    // Add 20% headroom to keep the peak below the top edge
    return maxVal == 0 ? 10 : (maxVal * 1.2).ceilToDouble();
  }

  double _calculateYInterval(List<dynamic> chartData) {
    final maxVal = _calculateMaxY(chartData);
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    if (maxVal <= 500) return 100;
    return (maxVal / 5).ceilToDouble();
  }
}

class _StatCard extends StatefulWidget {
  final Map<String, dynamic> stat;
  final bool isActive;
  final VoidCallback onTap;
  const _StatCard({required this.stat, required this.isActive, required this.onTap});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final color = widget.stat['color'] as Color;
    final showHighlight = widget.isActive || _isHovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(showHighlight ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: showHighlight ? color.withOpacity(0.4) : Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(widget.stat['icon'] as IconData, size: 22, color: color),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.stat['value'] as String, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text(widget.stat['title'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String type;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.onTap,
  });

  IconData get _icon {
    switch (type.toLowerCase()) {
      case 'application': return LucideIcons.userPlus;
      case 'job_post':
      case 'job': return LucideIcons.briefcase;
      case 'interview': return LucideIcons.calendar;
      case 'shortlist': return LucideIcons.star;
      case 'reject': return LucideIcons.xCircle;
      default: return LucideIcons.bell;
    }
  }

  Color get _color {
    switch (type.toLowerCase()) {
      case 'application': return const Color(0xFF6366F1);
      case 'job_post':
      case 'job': return const Color(0xFF10B981);
      case 'interview': return const Color(0xFF8B5CF6);
      case 'shortlist': return const Color(0xFFF59E0B);
      case 'reject': return const Color(0xFFF43F5E);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(_icon, size: 16, color: _color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      children: [
                        TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: ' $subtitle', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
