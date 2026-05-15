import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedJob = 'All Jobs';
  String _selectedDateRange = 'Last 30 Days';
  String? _selectedSource;

  final List<String> _dateOptions = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'];

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardDataProvider.future),
        color: AppColors.primary,
        child: dashboardAsync.when(
          loading: () => _buildLoadingState(),
          error: (err, stack) => _buildErrorState(err),
          data: (data) => _buildAnalyticsContent(data, isDesktop, isTablet),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(Object err) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to load analytics data', style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(dashboardDataProvider),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(Map<String, dynamic> data, bool isDesktop, bool isTablet) {
    // Extract real job titles for the filter
    final List<dynamic> recentJobs = data['recent_jobs'] ?? [];
    final List<String> jobTitles = ['All Jobs', ...recentJobs.map((j) => j['title']?.toString() ?? 'Unknown Job')];
    
    final stats = [
      {
        'title': 'Total Jobs',
        'value': (data['total_jobs'] ?? '0').toString(),
        'subtitle': '${data['active_jobs'] ?? 0} active',
        'icon': LucideIcons.briefcase,
        'color': const Color(0xFF6366F1), // Indigo
        'iconBg': const Color(0xFFEEF2FF),
      },
      {
        'title': 'Total Applications',
        'value': (data['total_applications'] ?? '0').toString(),
        'subtitle': 'Analytics ready',
        'icon': LucideIcons.users,
        'color': const Color(0xFFF43F5E), // Rose
        'iconBg': const Color(0xFFFFF1F2),
      },
      {
        'title': 'Interviews',
        'value': (data['interviews_scheduled'] ?? '0').toString(),
        'subtitle': 'Next 7 days',
        'icon': LucideIcons.calendar,
        'color': const Color(0xFFF59E0B), // Amber
        'iconBg': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Hired',
        'value': (data['hired_applications'] ?? '0').toString(),
        'subtitle': 'Growth +12%',
        'icon': LucideIcons.zap,
        'color': const Color(0xFF10B981), // Emerald
        'iconBg': const Color(0xFFECFDF5),
      },
    ];

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.light 
            ? [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)]
            : [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withOpacity(0.8)],
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 28),
            _buildFilters(isDesktop, jobTitles),
            const SizedBox(height: 32),
            
            // 1. Core Statistics
            _buildStatsGrid(stats, isDesktop, isTablet),
            const SizedBox(height: 32),

          // 2. Main Hiring Pipeline
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: RepaintBoundary(child: _buildHiringFunnel(data))),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: RepaintBoundary(child: _buildTimeToHire(data))),
              ],
            )
          else
            Column(
              children: [
                RepaintBoundary(child: _buildHiringFunnel(data)),
                const SizedBox(height: 24),
                RepaintBoundary(child: _buildTimeToHire(data)),
              ],
            ),
          const SizedBox(height: 32),

          // 3. Performance & Quality (Moved up for better visibility)
          RepaintBoundary(child: _buildJobPerformance(data)),
          const SizedBox(height: 32),

          // 4. Conversion & Effectiveness
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildOfferAcceptance(data)),
                const SizedBox(width: 24),
                Expanded(child: _buildCommunicationEffectiveness(data)),
              ],
            )
          else
            Column(
              children: [
                _buildOfferAcceptance(data),
                const SizedBox(height: 24),
                _buildCommunicationEffectiveness(data),
              ],
            ),
          const SizedBox(height: 32),

          // 5. Acquisition Insights (Sources, Location, Outcomes)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RepaintBoundary(child: _buildCandidateSources(data))),
                const SizedBox(width: 24),
                Expanded(child: _buildApplicationsByLocation(data)),
                const SizedBox(width: 24),
                Expanded(child: RepaintBoundary(child: _buildInterviewOutcomes(data))),
              ],
            )
          else
            Column(
              children: [
                RepaintBoundary(child: _buildCandidateSources(data)),
                const SizedBox(height: 24),
                _buildApplicationsByLocation(data),
                const SizedBox(height: 24),
                RepaintBoundary(child: _buildInterviewOutcomes(data)),
              ],
            ),
          const SizedBox(height: 32),

          // 6. System Activity & Engagement
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: RepaintBoundary(child: _buildActivityOverview(data))),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: RepaintBoundary(child: _buildNotificationSystem(data))),
              ],
            )
          else
            Column(
              children: [
                RepaintBoundary(child: _buildActivityOverview(data)),
                const SizedBox(height: 24),
                RepaintBoundary(child: _buildNotificationSystem(data)),
              ],
            ),
          const SizedBox(height: 32),

          // 7. Security & ROI
          _buildSystemSecurity(data),
          const SizedBox(height: 48),
        ],
      ),
    ),
  );
}

  Widget _buildCommunicationEffectiveness(Map<String, dynamic> data) {
    final comm = data['communication_effectiveness'] ?? {};
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Communication Effectiveness', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricMiniCard('Messages Sent', comm['messages_sent']?.toString() ?? '0', const Color(0xFFF43F5E))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricMiniCard('Replies Received', comm['replies_received']?.toString() ?? '0', const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricMiniCard('Avg Response Time', comm['avg_response_time']?.toString() ?? '0 hrs', const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricMiniCard('Missed Interviews', comm['missed_interviews']?.toString() ?? '0', const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 24),
          Text('Interview Invites Read Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (comm['read_rate'] ?? 0) / 100,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF43F5E)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${comm['read_rate'] ?? 0}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFF43F5E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSystem(Map<String, dynamic> data) {
    final notify = data['notification_system'] ?? {};
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(notify['total_sent']?.toString() ?? '0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                    Text('Total Sent', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${notify['delivery_rate'] ?? 0}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                    Text('Delivery Rate', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('${notify['open_rate'] ?? 0}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF43F5E))),
                    Text('Open Rate', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${notify['reminder_success'] ?? 0}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF43F5E))),
                    Text('Reminder Success', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: (notify['total_sent'] ?? 100).toDouble() * 1.2,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w600, fontSize: 10);
                        if (value.toInt() == 0) return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Sent', style: style));
                        if (value.toInt() == 1) return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Delivered', style: style));
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (notify['total_sent'] ?? 0).toDouble(), color: theme.dividerColor.withOpacity(0.05), width: 60, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (notify['total_sent'] ?? 0).toDouble() * 0.98, color: theme.dividerColor.withOpacity(0.05), width: 60, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverview(Map<String, dynamic> data) {
    final activity = data['activity_overview'] ?? {};
    final chartData = activity['chart_data'] as List? ?? [];
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniActivityStat('Profiles Viewed', activity['profiles_viewed']?.toString() ?? '0'),
              _buildMiniActivityStat('Resumes', activity['resumes_downloaded']?.toString() ?? '0'),
              _buildMiniActivityStat('Job Created', activity['jobs_created']?.toString() ?? '0'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7,
                      getTitlesWidget: (val, meta) {
                        if (val % 7 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Day ${val.toInt() + 1}', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w600)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['views'] as int).toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF6366F1),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['resumes'] as int).toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Views', const Color(0xFF6366F1)),
              const SizedBox(width: 24),
              _buildLegendItem('Resumes', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniActivityStat(String label, String val) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(width: 12, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildSystemSecurity(Map<String, dynamic> data) {
    final sys = data['system_security'] ?? {};
    final events = sys['security_events'] as List? ?? [];
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System & Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subscription ROI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.4))),
              Text(sys['subscription_roi']?.toString() ?? '0%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFE11D48)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Cost Per Hire', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(sys['cost_per_hire']?.toString() ?? '\$0', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Recent Security Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Text('No security logs available', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 12))
          else
            ...events.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['event'].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.8))),
                        Text(e['time'].toString(), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                      ],
                    ),
                  ),
                  Text(e['status'].toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Detailed insights into your recruitment and hiring metrics',
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (isDesktop)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download, size: 18, color: Colors.white),
              label: const Text('Export Report', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(bool isDesktop, List<String> jobTitles) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildFilterDropdown(_selectedJob, jobTitles, (val) => setState(() => _selectedJob = val!)),
        _buildFilterDropdown(_selectedDateRange, _dateOptions, (val) => setState(() => _selectedDateRange = val!)),
      ],
    );
  }

  Widget _buildFilterDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ] : [],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: Icon(LucideIcons.chevronDown, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          dropdownColor: theme.cardColor,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(List<Map<String, dynamic>> stats, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: stats.map((stat) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: stat == stats.last ? 0 : 20),
            child: _buildStatCard(stat),
          ),
        )).toList(),
      );
    }
    
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: stats.map((stat) => SizedBox(
        width: isTablet ? (MediaQuery.of(context).size.width - 64 - 20) / 2 : double.infinity,
        child: _buildStatCard(stat),
      )).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (stat['iconBg'] as Color),
                  (stat['iconBg'] as Color).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(stat['icon'] as IconData, size: 24, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat['title'] as String,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  stat['value'] as String,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, height: 1),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stat['subtitle'] as String,
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiringFunnel(Map<String, dynamic> data) {
    final funnel = data['hiring_funnel'] ?? {};
    final applied = (funnel['applied'] ?? 0) as num;
    final shortlisted = (funnel['shortlisted'] ?? 0) as num;
    final interviewed = (funnel['interviewed'] ?? 0) as num;
    final offered = (funnel['offered'] ?? 0) as num;
    final hired = (funnel['hired'] ?? 0) as num;
    final theme = Theme.of(context);

    final maxVal = applied == 0 ? 10.0 : applied.toDouble() * 1.1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hiring Funnel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              TextButton(
                onPressed: () => ref.refresh(dashboardDataProvider),
                child: const Text('Refresh', style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600, fontSize: 11);
                        switch (value.toInt()) {
                          case 0: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Applied', style: style));
                          case 1: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Shortlisted', style: style));
                          case 2: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Interviewed', style: style));
                          case 3: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Offered', style: style));
                          case 4: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Hired', style: style));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, applied.toDouble(), const Color(0xFF818CF8)),
                  _makeGroupData(1, shortlisted.toDouble(), const Color(0xFFC084FC)),
                  _makeGroupData(2, interviewed.toDouble(), const Color(0xFFF472B6)),
                  _makeGroupData(3, offered.toDouble(), const Color(0xFFFB923C)),
                  _makeGroupData(4, hired.toDouble(), const Color(0xFF4ADE80)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildFunnelStats(applied, shortlisted, interviewed, offered, hired),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 35,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Theme.of(context).dividerColor.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildFunnelStats(num a, num s, num i, num o, num h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMiniFunnelStat('Applied', a, 100),
        _buildMiniFunnelStat('Shortlisted', s, a == 0 ? 0 : (s / a * 100)),
        _buildMiniFunnelStat('Interviewed', i, a == 0 ? 0 : (i / a * 100)),
        _buildMiniFunnelStat('Offered', o, a == 0 ? 0 : (o / a * 100)),
        _buildMiniFunnelStat('Hired', h, a == 0 ? 0 : (h / a * 100)),
      ],
    );
  }

  Widget _buildMiniFunnelStat(String label, num val, num pct) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(val.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTimeToHire(Map<String, dynamic> data) {
    final tth = data['time_to_hire'] ?? {};
    final chartData = tth['chart_data'] as List? ?? [];

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time to Hire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricMiniCard('Posted to Application', tth['posted_to_app'] ?? '0 days', const Color(0xFF6366F1))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricMiniCard('Total Time to Hire', tth['total_time'] ?? '0 days', const Color(0xFFF43F5E))),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600);
                        switch (value.toInt()) {
                          case 0: return const Text('App', style: style);
                          case 1: return const Text('Shortlist', style: style);
                          case 2: return const Text('Interview', style: style);
                          case 3: return const Text('Offer', style: style);
                          case 4: return const Text('Hire', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF6366F1),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF6366F1).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricMiniCard(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildOfferAcceptance(Map<String, dynamic> data) {
    final oa = data['offer_acceptance'] ?? {};
    final rate = (oa['rate'] ?? 0) / 100.0;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Offer Acceptance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              Text('${oa['rate'] ?? 0}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: rate.toDouble(),
              minHeight: 12,
              backgroundColor: theme.dividerColor.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSimpleMetric('Offers Made', (oa['made'] ?? 0).toString())),
              Expanded(child: _buildSimpleMetric('Offers Accepted', (oa['accepted'] ?? 0).toString(), color: const Color(0xFF10B981), bg: theme.dividerColor.withOpacity(0.05))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String label, String val, {Color? color, Color? bg}) {
    final theme = Theme.of(context);
    final finalColor = color ?? theme.colorScheme.onSurface;
    final finalBg = bg ?? theme.dividerColor.withOpacity(0.05);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: finalBg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: finalColor)),
        ],
      ),
    );
  }

  Widget _buildCandidateSources(Map<String, dynamic> data) {
    final rawSources = (data['candidate_sources'] as List? ?? []);
    
    // Sort sources consistently to match required order
    final order = ['Paid', 'Organic', 'Referral', 'Social', 'Other'];
    final sources = order.map((name) {
      return rawSources.firstWhere((s) => s['name'] == name, orElse: () => {'name': name, 'count': 0});
    }).toList();

    final Map<String, Color> sourceColors = {
      'Paid': const Color(0xFFF97316),
      'Organic': const Color(0xFF10B981),
      'Referral': const Color(0xFFF59E0B),
      'Social': const Color(0xFFF43F5E),
      'Other': const Color(0xFF94A3B8),
    };

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Candidate Sources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              if (_selectedSource != null)
                TextButton(
                  onPressed: () => setState(() => _selectedSource = null),
                  child: const Text('Reset', style: TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            return;
                          }
                          // Use original sources to handle the click correctly
                          final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          
                          // If we are showing only one section, the index might be 0
                          if (_selectedSource != null) {
                             if (index == 0) {
                               setState(() => _selectedSource = null);
                             }
                             return;
                          }

                          if (index < 0 || index >= sources.length) return;
                          final sourceName = sources[index]['name'] as String;
                          setState(() => _selectedSource = sourceName);
                        },
                      ),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: _selectedSource == null 
                        ? sources.map((d) {
                            final name = d['name'] as String;
                            final color = sourceColors[name] ?? const Color(0xFF94A3B8);
                            final val = (d['count'] as num).toDouble();
                            return PieChartSectionData(
                              color: color,
                              value: val == 0 ? 0.1 : val,
                              title: '',
                              radius: 55,
                              showTitle: false,
                            );
                          }).toList()
                        : (() {
                            final d = sources.firstWhere((s) => s['name'] == _selectedSource);
                            final val = (d['count'] as num).toDouble();
                            if (val == 0) return <PieChartSectionData>[];
                            return [
                              PieChartSectionData(
                                color: sourceColors[_selectedSource] ?? const Color(0xFF94A3B8),
                                value: val,
                                title: '${d['count']}',
                                radius: 65,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                showTitle: true,
                              )
                            ];
                          })(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sources.map((s) {
                    final name = s['name'] as String;
                    final isSelected = _selectedSource == name;
                    final isDimmed = _selectedSource != null && !isSelected;
                    final color = sourceColors[name] ?? const Color(0xFF94A3B8);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedSource = (_selectedSource == name ? null : name)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isDimmed ? color.withOpacity(0.2) : color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isDimmed ? theme.colorScheme.onSurface.withOpacity(0.2) : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (_selectedSource != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (sourceColors[_selectedSource] ?? Colors.grey).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (sourceColors[_selectedSource] ?? Colors.grey).withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedSource!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: sourceColors[_selectedSource])),
                  Text(
                    '${sources.firstWhere((s) => s['name'] == _selectedSource)['count']} Candidates',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationsByLocation(Map<String, dynamic> data) {
    final locations = (data['applications_by_location'] as List? ?? []);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Applications by Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          ...locations.map((loc) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc['name'].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                    Text(loc['count'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (loc['count'] as num) / (data['total_applications'] == 0 ? 1 : data['total_applications']),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInterviewOutcomes(Map<String, dynamic> data) {
    final outcomes = data['interview_outcomes'] ?? {};
    final maxVal = [outcomes['passed'], outcomes['failed'], outcomes['no_show']].map((e) => (e ?? 0) as num).reduce((a, b) => a > b ? a : b).toDouble();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interview Outcomes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal * 1.2 : 10,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700, fontSize: 11);
                        switch (value.toInt()) {
                          case 0: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Passed', style: style));
                          case 1: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('Failed', style: style));
                          case 2: return Padding(padding: const EdgeInsets.only(top: 8), child: Text('No-show', style: style));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (outcomes['passed'] ?? 0).toDouble(), color: const Color(0xFF10B981), width: 40, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (outcomes['failed'] ?? 0).toDouble(), color: const Color(0xFFF43F5E), width: 40, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: (outcomes['no_show'] ?? 0).toDouble(), color: const Color(0xFF64748B), width: 40, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobPerformance(Map<String, dynamic> data) {
    final perf = data['job_performance'] as List? ?? [];
    
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Performance & Quality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 0,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(theme.dividerColor.withOpacity(0.05)),
              columns: [
                DataColumn(label: Text('JOB TITLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                DataColumn(label: Text('VIEWS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                DataColumn(label: Text('APPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                DataColumn(label: Text('CONVERSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                DataColumn(label: Text('RESUME SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                DataColumn(label: Text('SKILL MATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
              ],
              rows: perf.map((p) => DataRow(
                cells: [
                  DataCell(Text(p['title'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface))),
                  DataCell(Text(p['views'].toString(), style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
                  DataCell(Text(p['apps'].toString(), style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
                  DataCell(Text(p['conversion'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)))),
                  DataCell(Text(p['resume_score'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)))),
                  DataCell(Text(p['skill_match'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B)))),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
