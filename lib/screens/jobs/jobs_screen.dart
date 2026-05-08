import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/employer_jobs_provider.dart';
import '../candidates/candidates_screen.dart';
import '../candidates/candidate_details_screen.dart';
import 'post_job/post_job_wizard.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  int _selectedTab = 0;
  String _selectedStatus = 'All Status';
  final List<String> _tabs = const ['All jobs', 'Published', 'Drafts', 'Closed'];
  
  final List<String> _statusOptions = const [
    'All Status',
    'Active',
    'Draft',
    'Closed',
  ];

  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _activeSearchQuery = '';
  String _activeLocationQuery = '';
  String _activeStatusFilter = 'All Status';

  late final String _dateStr;

  @override
  void initState() {
    super.initState();
    final expiryDate = DateTime.now().add(const Duration(days: 365));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _dateStr = '${months[expiryDate.month - 1]} ${expiryDate.day}, ${expiryDate.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _activeSearchQuery = _searchController.text.trim();
      _activeLocationQuery = _locationController.text.trim();
      _activeStatusFilter = _selectedStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => ref.read(employerJobsProvider.notifier).fetchAll(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDesktop),
              const SizedBox(height: 32),
              _buildPlanCard(isDesktop),
              const SizedBox(height: 32),
              _buildStatusTabs(),
              const SizedBox(height: 32),
              _buildFilterCard(isDesktop),
              const SizedBox(height: 32),
              _buildJobsContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsContent() {
    final jobsAsync = ref.watch(employerJobsProvider);

    return jobsAsync.when(
      data: (stateData) {
        final jobs = stateData.jobs;
        if (jobs.isEmpty) return _buildEmptyState();
        
        // Filter jobs based on selected tab and active filters
        final filteredJobs = jobs.where((job) {
          // Tab filtering
          if (_selectedTab == 1 && job['status'] != 'active') return false;
          if (_selectedTab == 2 && job['status'] != 'draft') return false;
          if (_selectedTab == 3 && job['status'] != 'closed') return false;
          
          // Active filters (from Apply Filters button)
          if (_activeStatusFilter != 'All Status') {
            if (job['status']?.toString().toLowerCase() != _activeStatusFilter.toLowerCase()) return false;
          }
          
          if (_activeSearchQuery.isNotEmpty) {
            final title = job['title']?.toString().toLowerCase() ?? '';
            if (!title.contains(_activeSearchQuery.toLowerCase())) return false;
          }
          
          if (_activeLocationQuery.isNotEmpty) {
            final loc = job['location']?.toString().toLowerCase() ?? '';
            if (!loc.contains(_activeLocationQuery.toLowerCase())) return false;
          }
          
          return true;
        }).toList();

        if (filteredJobs.isEmpty) return _buildEmptyState();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredJobs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildJobCard(filteredJobs[index], stateData.applications);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(employerJobsProvider.notifier).fetchAll(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, List<dynamic> allApplications) {
    final status = job['status']?.toString().toLowerCase() ?? 'active';
    final isPublished = status == 'active';
    
    // Calculate dynamic stats from applications
    final jobId = job['id']?.toString();
    final jobApps = allApplications.where((app) => app['job_id']?.toString() == jobId).toList();
    
    final responsesCount = jobApps.length;
    final hotLeadsCount = jobApps.where((app) => app['status']?.toString().toLowerCase() == 'shortlisted').length;
    final newCandidatesCount = jobApps.where((app) => 
      app['status']?.toString().toLowerCase() == 'applied' || 
      app['status']?.toString().toLowerCase() == 'new' ||
      app['is_viewed'] == false || app['is_viewed'] == 0
    ).length;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          job['title'] ?? 'Untitled Job',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isPublished ? const Color(0xFF166534) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mindware info tech • ${job['location'] ?? 'Location not specified'}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editJob(job),
                icon: const Icon(LucideIcons.edit3, size: 18, color: Color(0xFF6366F1)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${job['experience'] ?? 'Any Exp'} | ${job['education'] ?? 'Graduate'} | ${job['language'] ?? 'English'} | ₹${job['salary_min'] ?? '0'} - ₹${job['salary_max'] ?? '0'} per month | ${job['type'] ?? 'Full time'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildJobStat(
                LucideIcons.messageSquare, 
                '$responsesCount Responses', 
                'From Candidates', 
                const Color(0xFFF0F7FF),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CandidatesScreen(jobId: jobId, initialTab: 0))),
              ),
              const SizedBox(width: 12),
              _buildJobStat(
                LucideIcons.zap, 
                '$hotLeadsCount Hot Leads', 
                'Shortlisted candidates', 
                const Color(0xFFFFF7ED),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CandidatesScreen(jobId: jobId, initialTab: 2))),
              ),
              const SizedBox(width: 12),
              _buildJobStat(
                LucideIcons.users, 
                '$newCandidatesCount New Candidates', 
                'Unviewed applications', 
                const Color(0xFFF0FDF4),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CandidatesScreen(jobId: jobId, initialTab: 1))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showApplicationsBottomSheet(job),
                  icon: const Icon(LucideIcons.users, size: 16),
                  label: const Text('Applications'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(employerJobsProvider.notifier).toggleJobStatus(
                    job['id'],
                    status == 'active',
                  ),
                  icon: Icon(isPublished ? LucideIcons.eyeOff : LucideIcons.eye, size: 16),
                  label: Text(isPublished ? 'Unpublish' : 'Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPublished ? const Color(0xFFF1F5F9) : const Color(0xFF4F46E5),
                    foregroundColor: isPublished ? const Color(0xFF64748B) : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted on: ${job['created_at_formatted'] ?? 'Just now'}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const Icon(LucideIcons.moreHorizontal, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobStat(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6366F1).withOpacity(0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
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
                'Jobs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your job postings',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
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
            onPressed: () => _openWizard(),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Post a Job'),
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

  Widget _buildPlanCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E7FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.zap, size: 20, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text(
                      'Current Plan: ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const Text(
                      'Free Plan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6366F1)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires on $_dateStr',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => ref.read(navigationProvider.notifier).setIndex(8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manage',
                  style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w700, fontSize: 12),
                ),
                SizedBox(width: 2),
                Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF6366F1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 0, // No extra left on first
              right: 12,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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

  Widget _buildFilterCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildFilterItem('Status', _buildDropdownField('All Status')),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildFilterItem('Search', _buildTextField(LucideIcons.search, 'Job title...', controller: _searchController)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildFilterItem('Location', _buildTextField(LucideIcons.mapPin, 'Location...', controller: _locationController)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildApplyButton(),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildFilterItem('Status', _buildDropdownField('All Status')),
                const SizedBox(height: 16),
                _buildFilterItem('Search', _buildTextField(LucideIcons.search, 'Job title...', controller: _searchController)),
                const SizedBox(height: 16),
                _buildFilterItem('Location', _buildTextField(LucideIcons.mapPin, 'Location...', controller: _locationController)),
                const SizedBox(height: 24),
                _buildApplyButton(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        field,
      ],
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: _applyFilters,
        icon: const Icon(LucideIcons.filter, size: 18),
        label: const Text('Apply Filters'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 18, color: Color(0xFF64748B)),
          items: _statusOptions.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val!),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.briefcase, size: 56, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No jobs found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get started by posting your first job.',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _openWizard(),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Post a job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
  void _openWizard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PostJobWizard(),
      ),
    );
  }

  void _editJob(Map<String, dynamic> job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PostJobWizard(jobData: job),
      ),
    );
  }

  void _showApplicationsBottomSheet(Map<String, dynamic> job) {
    final stateData = ref.read(employerJobsProvider).asData?.value;
    final allApps = stateData?.applications ?? [];
    
    // Filter applications for this specific job
    final targetJobId = job['id']?.toString();
    final jobApps = allApps.where((app) => app['job_id']?.toString() == targetJobId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Applications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${jobApps.length} Total',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                job['title'] ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: jobApps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users, size: 48, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          const Text('No applications yet', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: jobApps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final app = jobApps[index];
                        final candidate = app['candidate'] ?? {};
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFF8FAFC),
                                child: Text(
                                  (candidate['name']?[0] ?? 'C').toUpperCase(),
                                  style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate['name'] ?? 'Candidate Name',
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                    ),
                                    Text(
                                      candidate['email'] ?? '',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  app['status']?.toString().toUpperCase() ?? 'NEW',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
