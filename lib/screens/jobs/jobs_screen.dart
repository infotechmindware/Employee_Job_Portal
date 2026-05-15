import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/employer_jobs_provider.dart';
import '../candidates/candidate_applications_screen.dart';
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
  final List<String> _tabs = const ['All jobs', 'Published'];
  
  final List<String> _statusOptions = const [
    'All Status',
    'Active',
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        final seenIds = <String>{};
        final filteredJobs = jobs.where((job) {
          final id = job['id']?.toString();
          if (id == null || seenIds.contains(id)) return false;
          
          final status = job['status']?.toString().toLowerCase() ?? '';
          final isPublished = job['is_published'] == true || 
                              job['is_published'] == 1 || 
                              status == 'published' || 
                              status == 'active';
          
          // Tab filtering
          if (_selectedTab == 1 && !isPublished) return false;

          // Tab filtering
          if (_selectedTab == 1 && !isPublished) return false;
          
          // Active filters (from Apply Filters button)
          if (_activeStatusFilter != 'All Status') {
            if (status != 'active' && status != 'published') return false;
          }
          
          if (_activeSearchQuery.isNotEmpty) {
            final title = job['title']?.toString().toLowerCase() ?? '';
            if (!title.contains(_activeSearchQuery.toLowerCase())) return false;
          }
          
          if (_activeLocationQuery.isNotEmpty) {
            final loc = job['location']?.toString().toLowerCase() ?? '';
            if (!loc.contains(_activeLocationQuery.toLowerCase())) return false;
          }
          
          seenIds.add(id);
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
      error: (err, stack) {
        final theme = Theme.of(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(LucideIcons.alertCircle, color: theme.colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text('Error: $err', style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(employerJobsProvider.notifier).fetchAll(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, List<dynamic> allApplications) {
    final status = job['status']?.toString().toLowerCase() ?? 'active';
    final isPublished = status == 'active' || status == 'published';
    
    final jobId = job['id']?.toString();
    final jobApps = allApplications.where((app) => app['job_id']?.toString() == jobId).toList();
    
    final responsesCount = jobApps.length;
    final hotLeadsCount = jobApps.where((app) => app['status']?.toString().toLowerCase() == 'shortlisted').length;
    final newCandidatesCount = jobApps.where((app) => 
      app['status']?.toString().toLowerCase() == 'applied' || 
      app['status']?.toString().toLowerCase() == 'new'
    ).length;
    
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  job['title'] ?? 'Untitled Job',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(status, isPublished),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(LucideIcons.building2, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Mindware info tech • ${job['location'] ?? 'Location N/A'}',
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editJob(job),
                      icon: Icon(LucideIcons.moreVertical, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTag(LucideIcons.briefcase, job['experience'] ?? 'Any Exp'),
                      _buildTag(LucideIcons.graduationCap, job['education'] ?? 'Any Degree'),
                      _buildTag(LucideIcons.indianRupee, '₹${job['salary_min'] ?? '0'}-${job['salary_max'] ?? '0'}/mo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.03) : theme.scaffoldBackgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildStatItem(responsesCount.toString(), 'Responses', const Color(0xFF6366F1)),
                  _buildStatDivider(),
                  _buildStatItem(hotLeadsCount.toString(), 'Hot Leads', const Color(0xFFF59E0B)),
                  _buildStatDivider(),
                  _buildStatItem(newCandidatesCount.toString(), 'New', const Color(0xFF10B981)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    'Applications',
                    LucideIcons.users,
                    () => Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => CandidateApplicationsScreen(
                          jobId: jobId,
                          jobTitle: job['title'],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrimaryButton(
                    isPublished ? 'Unpublish' : 'Publish',
                    isPublished ? LucideIcons.eyeOff : LucideIcons.eye,
                    isPublished,
                    () async {
                      final wasPublished = status == 'active' || status == 'published';
                      await ref.read(employerJobsProvider.notifier).toggleJobStatus(job['id'], wasPublished);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isPublished) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublished ? (isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFDCFCE7).withOpacity(0.8)) : theme.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isPublished ? (isDark ? const Color(0xFF34D399) : const Color(0xFF166534)) : theme.colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.05) : theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: Theme.of(context).dividerColor.withOpacity(0.1));
  }

  Widget _buildPrimaryButton(String label, IconData icon, bool isPublished, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPublished ? (theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.05) : theme.dividerColor.withOpacity(0.1)) : null,
          gradient: isPublished ? null : const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPublished ? null : [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPublished ? theme.colorScheme.onSurface.withOpacity(0.6) : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPublished ? theme.colorScheme.onSurface.withOpacity(0.6) : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobStat(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return const SizedBox.shrink(); // Not used in new design, integrated into _buildJobCard
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
                'Jobs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your job postings',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : const Color(0xFFD0E7FF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.zap, size: 20, color: AppColors.primary),
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
                    Text(
                      'Current Plan: ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                    const Text(
                      'Free Plan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFF34D399) : const Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires on $_dateStr',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => ref.read(navigationProvider.notifier).setIndex(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Manage',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(width: 2),
                Icon(LucideIcons.arrowRight, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    final theme = Theme.of(context);
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
                  color: isSelected ? const Color(0xFF4F46E5) : theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : theme.dividerColor.withOpacity(0.1),
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
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : [],
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), letterSpacing: 0.5),
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
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.03) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
