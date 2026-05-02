import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedStatus = 'All Status';
  String _selectedSort = 'Latest';

  int? _activeStatIndex;
  int? _activeActivityIndex;
  int? _activeCandidateIndex;

  static const List<Map<String, dynamic>> _statsData = [
    {'title': 'Total Jobs', 'value': '142', 'change': '+12%', 'icon': LucideIcons.briefcase, 'color': Color(0xFF3B82F6)},
    {'title': 'Total Candidates', 'value': '8,249', 'change': '+24%', 'icon': LucideIcons.users, 'color': Color(0xFF8B5CF6)},
    {'title': 'Applications Received', 'value': '3,105', 'change': '+18%', 'icon': LucideIcons.fileText, 'color': Color(0xFF6366F1)},
    {'title': 'Shortlisted Candidates', 'value': '156', 'change': '+8%', 'icon': LucideIcons.userCheck, 'color': Color(0xFF10B981)},
  ];

  static const List<Map<String, dynamic>> _activitiesData = [
    {'title': 'New candidate applied', 'subtitle': 'Sarah Jenkins applied for UI Designer', 'time': '2m ago', 'icon': LucideIcons.userPlus, 'color': Color(0xFF3B82F6)},
    {'title': 'Job posted', 'subtitle': 'Senior Developer position is live', 'time': '1h ago', 'icon': LucideIcons.briefcase, 'color': Color(0xFF10B981)},
    {'title': 'Candidate shortlisted', 'subtitle': 'Michael Chen moved to Interview', 'time': '3h ago', 'icon': LucideIcons.star, 'color': Color(0xFFF59E0B)},
    {'title': 'Interview scheduled', 'subtitle': 'Tomorrow at 10:00 AM with Tech Lead', 'time': '5h ago', 'icon': LucideIcons.calendar, 'color': Color(0xFF8B5CF6)},
    {'title': 'Application rejected', 'subtitle': 'John Doe for Marketing Manager', 'time': '1d ago', 'icon': LucideIcons.xCircle, 'color': Color(0xFFEF4444)},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 700;

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
            _buildMiddleSection(isDesktop),
            const SizedBox(height: 40),
            _buildCandidatesTable(isDesktop),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -1.0,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Welcome back! Here is a summary of your platform activity.',
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatGrid(bool isDesktop, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 160,
      ),
      itemCount: _statsData.length,
      itemBuilder: (context, index) {
        return _StatCard(
          stat: _statsData[index],
          isActive: _activeStatIndex == index,
          onTap: () {
            setState(() {
              _activeStatIndex = _activeStatIndex == index ? null : index;
            });
          },
        );
      },
    );
  }

  Widget _buildMiddleSection(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildChartSection(),
          const SizedBox(height: 24),
          _buildActivitySection(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildChartSection()),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildActivitySection()),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Applications Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Text('This Week', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100], strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value >= 0 && value < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2), FlSpot(1, 3.5), FlSpot(2, 3), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6.5), FlSpot(6, 5.5),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF8B5CF6),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6366F1).withOpacity(0.15), const Color(0xFF8B5CF6).withOpacity(0)],
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

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activitiesData.length,
            itemBuilder: (context, index) {
              final act = _activitiesData[index];
              return _ActivityCard(
                title: act['title'] as String,
                subtitle: act['subtitle'] as String,
                time: act['time'] as String,
                icon: act['icon'] as IconData,
                color: act['color'] as Color,
                isActive: _activeActivityIndex == index,
                onTap: () {
                  setState(() {
                    _activeActivityIndex = _activeActivityIndex == index ? null : index;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesTable(bool isDesktop) {
    final candidates = [
      {'name': 'Priya Sharma', 'role': 'UI Designer', 'location': 'Delhi', 'status': 'Shortlisted', 'time': '2h ago'},
      {'name': 'Rahul Mehta', 'role': 'Backend Engineer', 'location': 'Mumbai', 'status': 'Applied', 'time': '5h ago'},
      {'name': 'Ananya Iyer', 'role': 'Product Manager', 'location': 'Bangalore', 'status': 'Rejected', 'time': '1d ago'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Candidates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Controls
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildSearchInput()),
                const SizedBox(width: 16),
                _buildStatusDropdown(),
                const SizedBox(width: 16),
                _buildSortDropdown(),
              ],
            )
          else
            Column(
              children: [
                _buildSearchInput(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatusDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSortDropdown()),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Candidate Cards
          ...List.generate(candidates.length, (index) {
            final c = candidates[index];
            return _CandidateCard(
              name: c['name']!,
              role: c['role']!,
              location: c['location']!,
              status: c['status']!,
              time: c['time']!,
              isDesktop: isDesktop,
              isActive: _activeCandidateIndex == index,
              onTap: () {
                setState(() {
                  _activeCandidateIndex = _activeCandidateIndex == index ? null : index;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return const _SearchInput();
  }

  Widget _buildStatusDropdown() {
    return _FilterDropdown(
      value: _selectedStatus,
      items: const ['All Status', 'Applied', 'Shortlisted', 'Rejected'],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
    );
  }

  Widget _buildSortDropdown() {
    return _FilterDropdown(
      value: _selectedSort,
      items: const ['Latest', 'Oldest'],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedSort = newValue;
          });
        }
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Stat Card
// -----------------------------------------------------------------------------
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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(showHighlight ? 1.02 : 1.0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: showHighlight ? color.withOpacity(0.4) : Colors.transparent, width: 2),
            boxShadow: [
              if (showHighlight)
                BoxShadow(color: color.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 12))
              else
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.stat['icon'] as IconData, size: 22, color: color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      widget.stat['change'] as String,
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stat['value'] as String,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stat['title'] as String,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Activity Card
// -----------------------------------------------------------------------------
class _ActivityCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final showHighlight = widget.isActive || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: showHighlight ? widget.color.withOpacity(0.04) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: showHighlight ? widget.color.withOpacity(0.2) : Colors.transparent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon, size: 16, color: widget.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(widget.time, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Candidate Card
// -----------------------------------------------------------------------------
class _CandidateCard extends StatefulWidget {
  final String name;
  final String role;
  final String location;
  final String status;
  final String time;
  final bool isDesktop;
  final bool isActive;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.name,
    required this.role,
    required this.location,
    required this.status,
    required this.time,
    required this.isDesktop,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  bool _isHovered = false;

  Color get _statusColor {
    switch (widget.status) {
      case 'Shortlisted': return const Color(0xFF10B981); // Green
      case 'Applied': return const Color(0xFFF59E0B); // Orange
      case 'Rejected': return const Color(0xFFEF4444); // Red
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showHighlight = widget.isActive || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(showHighlight ? 1.015 : 1.0),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: showHighlight ? const Color(0xFF6366F1).withOpacity(0.5) : const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              if (showHighlight) BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
              else BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: widget.isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildProfileCircle(),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(widget.role, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('•', style: TextStyle(color: Colors.grey))),
                  Icon(LucideIcons.mapPin, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(widget.location, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 6),
              Text('Applied ${widget.time}', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        _buildDesktopActions(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCircle(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('${widget.role} • ${widget.location}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusBadge(),
                      Text('Applied ${widget.time}', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            _buildMobileActionsDropdown(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCircle() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.name[0].toUpperCase(),
        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w800, fontSize: 18),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20), // Pill shape
      ),
      child: Text(
        widget.status,
        style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDesktopActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          tooltip: 'Shortlist',
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0FDF4), foregroundColor: const Color(0xFF10B981)),
          icon: const Icon(LucideIcons.check, size: 18),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          tooltip: 'Reject',
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), foregroundColor: const Color(0xFFEF4444)),
          icon: const Icon(LucideIcons.x, size: 18),
        ),
      ],
    );
  }

  Widget _buildMobileActionsDropdown() {
    return PopupMenuButton(
      icon: const Icon(LucideIcons.moreVertical, size: 20, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View Profile')),
        const PopupMenuItem(value: 'shortlist', child: Text('Shortlist', style: TextStyle(color: Color(0xFF10B981)))),
        const PopupMenuItem(value: 'reject', child: Text('Reject', style: TextStyle(color: Color(0xFFEF4444)))),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Search & Filter Controls
// -----------------------------------------------------------------------------
class _SearchInput extends StatefulWidget {
  const _SearchInput();

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _isFocused ? const Color(0xFF6366F1) : Colors.grey[200]!, width: _isFocused ? 2 : 1),
          boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), spreadRadius: 2, blurRadius: 0)] : [],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search candidates...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(LucideIcons.search, size: 18, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.value, required this.items, required this.onChanged});

  @override
  State<_FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<_FilterDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: _isFocused ? 11 : 12), // Adjust vertical padding for border width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused ? const Color(0xFF6366F1) : Colors.grey[200]!,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), spreadRadius: 2, blurRadius: 0)] : [],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.value,
            isExpanded: true,
            isDense: true,
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            onChanged: widget.onChanged,
            items: widget.items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
