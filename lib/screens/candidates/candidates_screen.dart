import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/candidates/filter_sidebar.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  int _selectedTab = 0;
  String _selectedJob = 'All Jobs';
  String _selectedSort = 'Application date (newest first)';

  final List<String> _tabs = [
    'All',
    'New',
    'Contacting',
    'Interviewed',
    'Rejected',
    'Hired',
    'Shortlist'
  ];

  final List<String> _sortOptions = [
    'Application date (newest first)',
    'Closest to location',
    'Most interested',
  ];

  final List<String> _jobOptions = [
    'All Jobs',
    'Senior Developer',
    'UI/UX Designer',
    'Product Manager',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWarningBanner(isDesktop),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 24),
            _buildTopFilters(isDesktop),
            const SizedBox(height: 24),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 280,
                    child: FilterSidebar(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildEmptyState(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const FilterSidebar(),
                  _buildEmptyState(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Candidates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage and review all job applications',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alertCircle, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 12),
              if (!isDesktop) 
                const Text('Upgrade Plan Required', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
            ],
          ),
          const SizedBox(height: 8),
          const Expanded(
            flex: 0,
            child: Text(
              'Upgrade to view candidate contact details and download resumes. You\'ve reached your contact view limit. Resume download limit reached.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF92400E),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 0 : 16),
          if (!isDesktop) const SizedBox(width: 0) else const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF3C7),
              foregroundColor: const Color(0xFF92400E),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Upgrade Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '0',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopFilters(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildRealDropdown(
                  label: 'Job:',
                  value: _selectedJob,
                  items: _jobOptions,
                  onChanged: (val) => setState(() => _selectedJob = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRealDropdown(
                  label: 'Sort:',
                  value: _selectedSort,
                  items: _sortOptions,
                  onChanged: (val) => setState(() => _selectedSort = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search candidates...',
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.black45),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildRealDropdown(
          label: 'Job:',
          value: _selectedJob,
          items: _jobOptions,
          onChanged: (val) => setState(() => _selectedJob = val!),
        ),
        const SizedBox(width: 16),
        _buildRealDropdown(
          label: 'Sort by:',
          value: _selectedSort,
          items: _sortOptions,
          onChanged: (val) => setState(() => _selectedSort = val!),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search name, email, skills...',
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.black45),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildIconButton(LucideIcons.filter, 'Filters'),
        const SizedBox(width: 8),
        _buildIconButton(LucideIcons.layoutGrid, null),
        const SizedBox(width: 8),
        _buildIconButton(LucideIcons.list, null, isActive: true),
      ],
    );
  }

  Widget _buildRealDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                elevation: 4,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Container(); // Obsolete, replaced by _buildRealDropdown
  }

  Widget _buildIconButton(IconData icon, String? label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isActive ? Colors.white : Colors.black54),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.black)),
          ],
        ],
      ),
    );
  }



  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 64, color: const Color(0xFFCBD5E1).withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text(
            'No applications found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Applications from candidates will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}
