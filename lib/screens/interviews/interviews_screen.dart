import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/job_service.dart';
import 'package:intl/intl.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});

  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen> {
  int _selectedTab = 0;
  String _selectedType = 'All Types';
  String _selectedSort = 'Latest First';

  List<dynamic> _interviews = [];
  Map<String, dynamic> _apiStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
  }

  Future<void> _fetchInterviews() async {
    setState(() {
      _isLoading = true;
    });
    final result = await JobService.getEmployerInterviews();
    setState(() {
      _interviews = result['interviews'] ?? [];
      _apiStats = result['stats'] ?? {};
      _isLoading = false;
    });
  }

  final List<String> _tabs = ['All', 'Upcoming', 'Today', 'This Week', 'Completed', 'Declined'];
  
  final List<String> _typeOptions = ['All Types', 'Technical', 'HR', 'Behavioral'];
  final List<String> _sortOptions = ['Latest First', 'Oldest First', 'A-Z', 'Z-A'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 32),
            _buildStatsCards(isDesktop),
            const SizedBox(height: 32),
            _buildTabAndFilters(isDesktop),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_interviews.isEmpty)
              _buildEmptyState()
            else
              _buildInterviewList(),
          ],
        ),
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
                'Interviews',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and track all candidate interviews',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showScheduleDialog(context),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Schedule Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  int get totalInterviews => _interviews.length;
  
  int get scheduledInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'upcoming' || status == 'scheduled' || status == 'live' || status == 'interviewing' || status == 'pending';
    }).length;
  }
  
  int get todayInterviews {
    final now = DateTime.now();
    return _interviews.where((i) {
      final start = i['scheduled_start']?.toString() ?? '';
      if (start.isEmpty) return false;
      try {
        final date = DateTime.parse(start);
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  int get next7DaysInterviews {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _interviews.where((i) {
      final start = i['scheduled_start']?.toString() ?? '';
      if (start.isEmpty) return false;
      try {
        final date = DateTime.parse(start);
        return date.isAfter(now) && date.isBefore(nextWeek);
      } catch (e) {
        return false;
      }
    }).length;
  }

  int get finishedInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'completed' || status == 'done' || status == 'finished';
    }).length;
  }

  int get declinedInterviews {
    return _interviews.where((i) {
      final status = i['status']?.toString().toLowerCase() ?? '';
      return status == 'declined' || status == 'missed' || status == 'cancelled' || status == 'withdrawn';
    }).length;
  }

  Widget _buildStatsCards(bool isDesktop) {
    final stats = [
      {'title': 'TOTAL', 'value': (_apiStats['total'] ?? totalInterviews).toString(), 'subtitle': 'All time', 'icon': LucideIcons.barChart2, 'color': const Color(0xFF64748B)},
      {'title': 'UPCOMING', 'value': (_apiStats['upcoming'] ?? scheduledInterviews).toString(), 'subtitle': 'Scheduled', 'icon': LucideIcons.calendar, 'color': const Color(0xFF6366F1)},
      {'title': 'TODAY', 'value': (_apiStats['today'] ?? todayInterviews).toString(), 'subtitle': 'Today', 'icon': LucideIcons.clock, 'color': const Color(0xFF3B82F6)},
      {'title': 'WEEK', 'value': (_apiStats['week'] ?? next7DaysInterviews).toString(), 'subtitle': 'Next 7 days', 'icon': LucideIcons.calendarDays, 'color': const Color(0xFF8B5CF6)},
      {'title': 'DONE', 'value': (_apiStats['completed'] ?? finishedInterviews).toString(), 'subtitle': 'Finished', 'icon': LucideIcons.checkCircle, 'color': const Color(0xFF10B981)},
      {'title': 'DECLINED', 'value': (_apiStats['missed'] ?? declinedInterviews).toString(), 'subtitle': 'Missed', 'icon': LucideIcons.xCircle, 'color': const Color(0xFFEF4444)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 6 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.2 : 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildStatCard(stats[index], isDesktop);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'] as IconData, size: 16, color: stat['color'] as Color),
              ),
              Text(
                stat['title'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['subtitle'] as String,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTabAndFilters(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabs(),
        const SizedBox(height: 24),
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                boxShadow: theme.brightness == Brightness.light ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ] : [],
              ),
              child: Column(
                children: [
                  _buildSearchField(double.infinity),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdownField(_selectedType, _typeOptions, (val) => setState(() => _selectedType = val!), AlignmentDirectional.centerStart)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownField(_selectedSort, _sortOptions, (val) => setState(() => _selectedSort = val!), AlignmentDirectional.centerEnd)),
                    ],
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchField(double width) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: 52,
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search interviews...',
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          filled: true,
          fillColor: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value, List<String> items, ValueChanged<String?> onChanged, AlignmentGeometry menuAlignment) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          alignment: menuAlignment,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: theme.cardColor,
          elevation: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            alignment: menuAlignment,
            child: Text(val),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.calendar, size: 56, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Interviews Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule your first interview to get started.',
            style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showScheduleDialog(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Schedule Interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Interview',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the details to set up a new meeting',
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildLabel('Select Candidate'),
                _buildDialogField(LucideIcons.user, 'Search candidate name...'),
                const SizedBox(height: 16),
                
                _buildLabel('Assign Interviewer'),
                _buildDialogDropdown(['Select Interviewer', 'Sarah Johnson (HR)', 'Michael Chen (Tech)', 'Emily Davis (Product)']),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Date'),
                          _buildDialogField(LucideIcons.calendar, 'Oct 24, 2026'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Time'),
                          _buildDialogField(LucideIcons.clock, '10:30 AM'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildLabel('Interview Mode'),
                _buildDialogDropdown(['Video Call (Google Meet)', 'In-Person (Office)', 'Phone Call']),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildDialogField(IconData icon, String hint) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDialogDropdown(List<String> items) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items[0],
          isExpanded: true,
          dropdownColor: theme.cardColor,
          items: items.map((String val) => DropdownMenuItem<String>(
            value: val,
            child: Text(val, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          )).toList(),
          onChanged: (val) {},
          icon: Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildInterviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _interviews.length,
      itemBuilder: (context, index) {
        final interview = _interviews[index];
        return _buildInterviewCard(interview);
      },
    );
  }

  Widget _buildInterviewCard(dynamic interview) {
    final candidate = interview['candidate'] ?? {};
    final job = interview['job'] ?? {};
    
    final candidateName = candidate['full_name'] ?? interview['candidate_name'] ?? 'Unknown Candidate';
    final candidateImage = candidate['profile_image'] ?? candidate['avatar'] ?? interview['candidate_image'];
    final jobTitle = job['title'] ?? interview['job_title'] ?? 'Unknown Job';
    
    final status = (interview['status']?.toString() ?? 'Pending').toUpperCase();
    final interviewType = interview['interview_type']?.toString() ?? 'Online';
    
    // Format Date & Time properly
    final String startStr = interview['scheduled_start']?.toString() ?? '';
    final String endStr = interview['scheduled_end']?.toString() ?? '';
    String formattedDateTime = 'TBD - TBD';
    
    if (startStr.isNotEmpty) {
      try {
        final startDate = DateTime.parse(startStr);
        final datePart = DateFormat('MMM dd, yyyy').format(startDate);
        final startTime = DateFormat('hh:mm a').format(startDate);
        formattedDateTime = '$datePart | $startTime';
        
        if (endStr.isNotEmpty) {
          final endDate = DateTime.parse(endStr);
          final endTime = DateFormat('hh:mm a').format(endDate);
          formattedDateTime += ' - $endTime';
        }
      } catch (e) {
        formattedDateTime = '$startStr - $endStr';
      }
    }

    final meetingLink = interview['meeting_link']?.toString() ?? '';
    final bool isLive = status == 'LIVE' || status == 'INTERVIEWING';

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: candidateImage != null && candidateImage.toString().isNotEmpty 
                    ? NetworkImage(candidateImage.toString()) 
                    : null,
                child: candidateImage == null || candidateImage.toString().isEmpty
                    ? const Icon(LucideIcons.user, color: Color(0xFF94A3B8))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jobTitle,
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.video, 'Type', interviewType),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.calendar, 'Date & Time', formattedDateTime),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: const Text('View Details', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              if (meetingLink.isNotEmpty && isLive) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.video, size: 16),
                    label: const Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
