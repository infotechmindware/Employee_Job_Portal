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

  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'Alex Johnson',
      'role': 'Senior Developer',
      'experience': '5 years',
      'status': 'New',
      'image': 'https://i.pravatar.cc/150?u=alex',
    },
    {
      'name': 'Sarah Smith',
      'role': 'UI/UX Designer',
      'experience': '3 years',
      'status': 'Contacted',
      'image': 'https://i.pravatar.cc/150?u=sarah',
    },
    {
      'name': 'Michael Brown',
      'role': 'Product Manager',
      'experience': '8 years',
      'status': 'New',
      'image': 'https://i.pravatar.cc/150?u=michael',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildUpgradeCard(isDesktop),
            const SizedBox(height: 32),
            _buildStatusCards(),
            const SizedBox(height: 32),
            _buildFilterSection(isDesktop),
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
                    child: _buildCandidateList(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const FilterSidebar(),
                  const SizedBox(height: 24),
                  _buildCandidateList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Candidates',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and review all job applications',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // Smaller Folder Icon
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(LucideIcons.folder, size: 40, color: Colors.deepPurple.shade200),
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.user, size: 16, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFDBA74)),
                      ),
                      child: const Icon(LucideIcons.alertCircle, color: Color(0xFFEA580C), size: 16),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        'Upgrade Plan Required',
                        style: TextStyle(
                          color: Color(0xFF9A3412),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upgrade to view candidate contact details and download resumes. You\'ve reached your limit.',
                  style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Upgrade Plan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) const SizedBox(width: 40),
          // Shield Lock Icon (Smaller)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.shieldAlert, size: 48, color: Color(0xFFFDBA74)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final List<Map<String, dynamic>> statusOptions = [
      {'label': 'All', 'count': '124', 'icon': LucideIcons.users, 'color': Colors.deepPurple},
      {'label': 'New', 'count': '12', 'icon': LucideIcons.userPlus, 'color': Colors.green},
      {'label': 'Contacting', 'count': '45', 'icon': LucideIcons.phone, 'color': Colors.blue},
      {'label': 'Interviewed', 'count': '28', 'icon': LucideIcons.calendar, 'color': Colors.indigo},
      {'label': 'Rejected', 'count': '15', 'icon': LucideIcons.userX, 'color': Colors.red},
      {'label': 'Hired', 'count': '8', 'icon': LucideIcons.userCheck, 'color': Colors.teal},
      {'label': 'Shortlist', 'count': '16', 'icon': LucideIcons.bookmark, 'color': Colors.amber},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 600 ? 7 : 4;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Disable all scrolling/stretching
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.9, // Nearly square for balance
          ),
          itemCount: statusOptions.length,
          itemBuilder: (context, index) {
            final status = statusOptions[index];
            final isSelected = _selectedTab == index;
            return InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? Colors.deepPurple.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.01),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(status['icon'], color: status['color'], size: 14),
                    const SizedBox(height: 6),
                    Text(
                      status['label'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      status['count'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.deepPurple : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                icon: LucideIcons.briefcase,
                label: 'Job',
                value: _selectedJob,
                items: _jobOptions,
                onChanged: (val) => setState(() => _selectedJob = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterDropdown(
                icon: LucideIcons.listFilter,
                label: 'Sort by',
                value: _selectedSort,
                items: _sortOptions,
                onChanged: (val) => setState(() => _selectedSort = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search candidates...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon: Icon(LucideIcons.search, size: 20, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(LucideIcons.slidersHorizontal, color: Colors.deepPurple, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCardContent() {
    return Container(); // No longer used as it was merged into _buildUpgradeCard
  }

  Widget _buildTabs() {
    return Container(); // No longer used as it was replaced by _buildStatusCards
  }

  Widget _buildTopFilters(bool isDesktop) {
    return Container(); // No longer used as it was replaced by _buildFilterSection
  }

  Widget _buildRealDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(); // No longer used
  }

  Widget _buildCandidateList() {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    if (_candidates.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _candidates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCandidateCard(_candidates[index], isDesktop);
      },
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(candidate['image']),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            candidate['name'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(candidate['status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${candidate['role']} • ${candidate['experience']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    _buildActionButton(LucideIcons.eye, 'View', Colors.grey.shade100, const Color(0xFF64748B)),
                    const SizedBox(width: 12),
                    _buildActionButton(LucideIcons.mail, 'Contact', AppColors.primary.withOpacity(0.1), AppColors.primary),
                  ],
                ),
              ],
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(LucideIcons.eye, 'View', Colors.grey.shade100, const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(LucideIcons.mail, 'Contact', AppColors.primary.withOpacity(0.1), AppColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isNew = status == 'New';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isNew ? AppColors.primary : const Color(0xFF059669),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
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
        borderRadius: BorderRadius.circular(16),
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
