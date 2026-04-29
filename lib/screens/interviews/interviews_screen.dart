import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  int _selectedTab = 0;
  String _selectedType = 'All Types';
  String _selectedSort = 'Latest First';

  final List<String> _tabs = ['All', 'Upcoming', 'Today', 'This Week', 'Completed', 'Declined'];
  
  final List<String> _typeOptions = ['All Types', 'Technical', 'HR', 'Behavioral'];
  final List<String> _sortOptions = ['Latest First', 'Oldest First', 'A-Z', 'Z-A'];

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
            _buildStatsCards(isDesktop),
            const SizedBox(height: 32),
            _buildTabAndFilters(isDesktop),
            const SizedBox(height: 24),
            _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interviews',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 4),
            Text(
              'Manage and track all your candidate interviews',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Schedule Interview'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    final stats = [
      {'title': 'TOTAL', 'value': '0', 'subtitle': 'All time interviews', 'icon': LucideIcons.barChart2, 'color': const Color(0xFF64748B)},
      {'title': 'UPCOMING', 'value': '0', 'subtitle': 'Scheduled future', 'icon': LucideIcons.calendar, 'color': const Color(0xFF6366F1)},
      {'title': 'TODAY', 'value': '0', 'subtitle': 'Happening today', 'icon': LucideIcons.clock, 'color': const Color(0xFF3B82F6)},
      {'title': 'WEEK', 'value': '0', 'subtitle': 'Next 7 days', 'icon': LucideIcons.calendarDays, 'color': const Color(0xFF8B5CF6)},
      {'title': 'DONE', 'value': '0', 'subtitle': 'Successfully finished', 'icon': LucideIcons.checkCircle, 'color': const Color(0xFF10B981)},
      {'title': 'DECLINED', 'value': '0', 'subtitle': 'Withdrawn/Missed', 'icon': LucideIcons.xCircle, 'color': const Color(0xFFEF4444)},
    ];

    if (!isDesktop) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stats.map((stat) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildStatCard(stat, isDesktop),
          )).toList(),
        ),
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildStatCard(stat, isDesktop),
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    return Container(
      width: isDesktop ? null : 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat['icon'] as IconData, size: 18, color: stat['color'] as Color),
              Text(
                stat['title'] as String,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: (stat['color'] as Color).withOpacity(0.8), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text(
            stat['subtitle'] as String,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabAndFilters(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabs(),
          const SizedBox(height: 24),
          _buildMobileFilters(),
        ],
      );
    }

    return Row(
      children: [
        _buildTabs(),
        const Spacer(),
        _buildDesktopFilters(),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                children: [
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: 20,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        _buildSearchField(200),
        const SizedBox(width: 12),
        _buildDropdownField(_selectedType, _typeOptions, (val) => setState(() => _selectedType = val!), 120),
        const SizedBox(width: 12),
        _buildDropdownField(_selectedSort, _sortOptions, (val) => setState(() => _selectedSort = val!), 120),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        _buildSearchField(double.infinity),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDropdownField(_selectedType, _typeOptions, (val) => setState(() => _selectedType = val!), double.infinity)),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdownField(_selectedSort, _sortOptions, (val) => setState(() => _selectedSort = val!), double.infinity)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(double width) {
    return SizedBox(
      width: width,
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value, List<String> items, ValueChanged<String?> onChanged, double width) {
    return Container(
      width: width,
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
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF94A3B8)),
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            child: Text(val, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.calendar, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 24),
          const Text(
            'No Interviews Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schedule your first interview to get started.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Schedule Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
