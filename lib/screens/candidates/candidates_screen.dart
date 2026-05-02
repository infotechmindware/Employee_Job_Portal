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
  static const List<String> _tabsData = [
    'All',
    'New',
    'Contacting',
    'Interviewed',
    'Rejected',
    'Hired',
    'Shortlist'
  ];

  static const List<String> _sortOptionsData = [
    'Application date (newest first)',
    'Closest to location',
    'Most interested',
  ];

  static const List<String> _jobOptionsData = [
    'All Jobs',
    'Senior Developer',
    'UI/UX Designer',
    'Product Manager',
  ];

  static const List<Map<String, dynamic>> _candidatesData = [
    {
      'name': 'Alex Johnson',
      'role': 'Senior Developer',
      'location': 'Bangalore, India',
      'status': 'Applied',
      'time': '2h ago',
      'image': 'https://i.pravatar.cc/150?u=alex',
    },
    {
      'name': 'Sarah Smith',
      'role': 'UI/UX Designer',
      'location': 'Delhi, India',
      'status': 'Shortlisted',
      'time': '5h ago',
      'image': 'https://i.pravatar.cc/150?u=sarah',
    },
    {
      'name': 'Michael Brown',
      'role': 'Product Manager',
      'location': 'Mumbai, India',
      'status': 'Rejected',
      'time': '1d ago',
      'image': 'https://i.pravatar.cc/150?u=michael',
    },
    {
      'name': 'Emily Davis',
      'role': 'Frontend Engineer',
      'location': 'Remote',
      'status': 'Shortlisted',
      'time': '2d ago',
      'image': 'https://i.pravatar.cc/150?u=emily',
    },
    {
      'name': 'Daniel Wilson',
      'role': 'Backend Engineer',
      'location': 'Pune, India',
      'status': 'Applied',
      'time': '3d ago',
      'image': 'https://i.pravatar.cc/150?u=daniel',
    },
  ];

  int _selectedTab = 0;
  String _selectedJob = 'All Jobs';
  String _selectedSort = 'Application date (newest first)';
  int? _activeCandidateIndex;

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
                    child: _buildCandidateList(isDesktop),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const FilterSidebar(),
                  const SizedBox(height: 24),
                  _buildCandidateList(isDesktop),
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
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.9,
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
              child: _FilterDropdown(
                icon: LucideIcons.briefcase,
                label: 'Job',
                value: _selectedJob,
                items: _jobOptionsData,
                onChanged: (val) => setState(() => _selectedJob = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _FilterDropdown(
                icon: LucideIcons.listFilter,
                label: 'Sort by',
                value: _selectedSort,
                items: _sortOptionsData,
                onChanged: (val) => setState(() => _selectedSort = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SearchInput()),
            const SizedBox(width: 16),
            const _FilterIconButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildCandidateList(bool isDesktop) {
    if (_candidatesData.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 220,
      ),
      itemCount: _candidatesData.length,
      itemBuilder: (context, index) {
        final c = _candidatesData[index];
        return _ModernCandidateCard(
          name: c['name']!,
          role: c['role']!,
          location: c['location']!,
          status: c['status']!,
          time: c['time']!,
          imageUrl: c['image']!,
          isActive: _activeCandidateIndex == index,
          onTap: () {
            setState(() {
              _activeCandidateIndex = _activeCandidateIndex == index ? null : index;
            });
          },
        );
      },
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

// -----------------------------------------------------------------------------
// Interactive Modern Candidate Card
// -----------------------------------------------------------------------------
class _ModernCandidateCard extends StatefulWidget {
  final String name;
  final String role;
  final String location;
  final String status;
  final String time;
  final String imageUrl;
  final bool isActive;
  final VoidCallback onTap;

  const _ModernCandidateCard({
    required this.name,
    required this.role,
    required this.location,
    required this.status,
    required this.time,
    required this.imageUrl,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ModernCandidateCard> createState() => _ModernCandidateCardState();
}

class _ModernCandidateCardState extends State<_ModernCandidateCard> {
  bool _isHovered = false;

  Color get _statusColor {
    switch (widget.status) {
      case 'Shortlisted': return const Color(0xFF10B981); // Green
      case 'Applied': return const Color(0xFFF59E0B); // Orange
      case 'Rejected': return const Color(0xFFEF4444); // Red
      default: return const Color(0xFF3B82F6); // Blue fallback
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
          transform: Matrix4.identity()..scale(showHighlight ? 1.02 : 1.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showHighlight ? const Color(0xFF6366F1).withOpacity(0.5) : const Color(0xFFE2E8F0), 
              width: 1.5,
            ),
            boxShadow: [
              if (showHighlight) 
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
              else 
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Profile & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(widget.imageUrl),
                        backgroundColor: const Color(0xFFEEF2FF),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(widget.role, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 16),
              // Location & Time Info
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(widget.location, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Icon(LucideIcons.clock, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text('Applied ${widget.time}', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                ],
              ),
              const Spacer(),
              // Bottom Action Buttons (Always visible on mobile, fade in on desktop if hovered/active)
              AnimatedOpacity(
                opacity: showHighlight || MediaQuery.of(context).size.width < 1024 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF8FAFC),
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.user, size: 16),
                        label: const Text('View Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FF),
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.checkCircle2, size: 16),
                        label: const Text('Shortlist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.status,
        style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    );
  }
}

class _FilterDropdown extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.icon, required this.label, required this.value, required this.items, required this.onChanged});

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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: _isFocused ? 7 : 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), spreadRadius: 2, blurRadius: 0)] : [],
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.deepPurple, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.value,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: widget.items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
                          ),
                        );
                      }).toList(),
                      onChanged: widget.onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends StatefulWidget {
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), width: _isFocused ? 2 : 1),
          boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), spreadRadius: 2, blurRadius: 0)] : [],
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
    );
  }
}

class _FilterIconButton extends StatefulWidget {
  const _FilterIconButton();

  @override
  State<_FilterIconButton> createState() => _FilterIconButtonState();
}

class _FilterIconButtonState extends State<_FilterIconButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: InkWell(
        onTap: () {
          // Action for filter icon
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(_isFocused ? 15 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), width: _isFocused ? 2 : 1),
            boxShadow: _isFocused ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), spreadRadius: 2, blurRadius: 0)] : [],
          ),
          child: const Icon(LucideIcons.slidersHorizontal, color: Colors.deepPurple, size: 24),
        ),
      ),
    );
  }
}
