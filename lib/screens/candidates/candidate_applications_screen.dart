import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'candidate_details_screen.dart';
import '../subscription/subscription_plans_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/chat_service.dart';
import '../messaging/chat_detail_screen.dart';
import '../../services/job_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/employer_jobs_provider.dart';
import '../../providers/navigation_provider.dart';

class CandidateApplicationsScreen extends ConsumerStatefulWidget {
  final String? jobId;
  final String? jobTitle;

  const CandidateApplicationsScreen({
    super.key,
    this.jobId,
    this.jobTitle,
  });

  @override
  ConsumerState<CandidateApplicationsScreen> createState() => _CandidateApplicationsScreenState();
}

class _CandidateApplicationsScreenState extends ConsumerState<CandidateApplicationsScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];
  List<dynamic> _jobs = [];
  Map<String, dynamic>? _selectedJob;
  int _selectedTab = 0;
  String _selectedSortBy = 'Application date (newest first)';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tabs = ['All', 'New', 'Contacting', 'Interviewed', 'Rejected', 'Hired', 'Shortlist'];

  // Filter States
  String _filterLocation = '';
  int? _filterDistance;
  double? _filterMinExp;
  double? _filterMaxExp;
  int? _filterActiveIn;
  List<String> _filterSkills = [];
  String _filterEnglishFluency = 'Any';

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _fetchApplications();
  }

  Future<void> _fetchJobs() async {
    try {
      final data = await JobService.getEmployerJobs();
      if (mounted) setState(() => _jobs = data);
    } catch (e) {}
  }

  Future<void> _fetchApplications() async {
    // We now use the global provider, so we just refresh it
    await ref.read(employerJobsProvider.notifier).fetchAll(showLoading: false);
  }

  void _clearFilters() {
    setState(() {
      _filterLocation = '';
      _filterDistance = null;
      _filterMinExp = null;
      _filterMaxExp = null;
      _filterActiveIn = null;
      _filterSkills = [];
      _filterEnglishFluency = 'Any';
      _searchController.clear();
    });
    _fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    final bool isJobSelected = _selectedJob != null;
    final employerState = ref.watch(employerJobsProvider);
    
    // Sync tab with navigation provider if needed
    final navState = ref.watch(navigationProvider);
    if (navState.activeIndex == 2 && _selectedTab != navState.applicationsTabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedTab = navState.applicationsTabIndex);
        }
      });
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: _buildFilterDrawer(),
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isJobSelected ? (_selectedJob!['title'] ?? 'Job Details') : 'All Candidates',
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(LucideIcons.filter, color: theme.primaryColor, size: 22),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: employerState.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          final allApps = state.applications;
          
          // Preload first 10 images for instant rendering
          for (int i = 0; i < allApps.length && i < 10; i++) {
            final cand = allApps[i]['candidate'] ?? {};
            String? img = cand['profile_image'] ?? allApps[i]['profile_picture'];
            if (img != null) {
              if (!img.startsWith('http')) img = "https://www.mindwareinfotech.com$img";
              precacheImage(CachedNetworkImageProvider(img), context);
            }
          }
          
          // Filter by Job if selected
          final jobFiltered = isJobSelected 
              ? allApps.where((app) => app['job_id']?.toString() == _selectedJob?['id']?.toString()).toList()
              : allApps;

          // Calculate counts for all tabs from job-filtered list
          Map<String, int> tabCounts = {};
          tabCounts['All'] = jobFiltered.length;
                    for (int i = 1; i < _tabs.length; i++) {
              final tab = _tabs[i];
              // Map UI tab name to backend status
              String statusKey = tab.toLowerCase();
              if (tab == 'Shortlist' || tab == 'Shortlisted') statusKey = 'shortlisted';
              if (tab == 'Interviewed') statusKey = 'interviewing';
              
              tabCounts[tab] = jobFiltered.where((app) {
                final s = app['status']?.toString().toLowerCase();
                if (tab == 'New' && (s == 'applied' || s == 'new' || s == 'pending' || s == 'fresh')) return true;
                if (tab == 'Interviewed' && (s == 'interviewed' || s == 'interviewing' || s == 'interview')) return true;
                if (tab == 'Shortlist' || tab == 'Shortlisted') {
                  return s == 'shortlisted' || s == 'shortlist';
                }
                return s == statusKey;
              }).length;
            }

            // Filter by selected Tab
            final currentTabName = _tabs[_selectedTab];
            var filteredApps = currentTabName == 'All' 
                ? jobFiltered 
                : jobFiltered.where((app) {
                    final s = app['status']?.toString().toLowerCase();
                    String statusKey = currentTabName.toLowerCase();
                    if (currentTabName == 'Shortlist' || currentTabName == 'Shortlisted') statusKey = 'shortlisted';
                    if (currentTabName == 'Interviewed') statusKey = 'interviewing';
                    
                    if (currentTabName == 'New' && (s == 'applied' || s == 'new' || s == 'pending' || s == 'fresh')) return true;
                    if (currentTabName == 'Interviewed' && (s == 'interviewed' || s == 'interviewing' || s == 'interview')) return true;
                    if (currentTabName == 'Shortlist' || currentTabName == 'Shortlisted') {
                      return s == 'shortlisted' || s == 'shortlist';
                    }
                    return s == statusKey;
                  }).toList();

            // Filter by Search Query (Case-insensitive & Real-time)
            final query = _searchController.text.toLowerCase().trim();
            if (query.isNotEmpty) {
              filteredApps = filteredApps.where((app) {
                final candidate = app['candidate'] ?? {};
                final name = (candidate['full_name'] ?? app['full_name'] ?? "").toString().toLowerCase();
                final email = (candidate['email'] ?? app['candidate_email'] ?? "").toString().toLowerCase();
                final phone = (candidate['phone'] ?? candidate['mobile'] ?? app['candidate_mobile'] ?? "").toString().toLowerCase();
                
                // Skills search handling
                String skillsStr = "";
                final rawSkills = app['skills_data'] ?? candidate['skills'] ?? candidate['skills_data'] ?? [];
                if (rawSkills is List) {
                  skillsStr = rawSkills.map((e) {
                    if (e is Map) return e['name']?.toString() ?? e.toString();
                    return e.toString();
                  }).join(', ').toLowerCase();
                } else {
                  skillsStr = rawSkills.toString().toLowerCase();
                }
                
                return name.contains(query) || 
                       email.contains(query) || 
                       phone.contains(query) || 
                       skillsStr.contains(query);
              }).toList();
            }

          return RefreshIndicator(
            onRefresh: () => ref.read(employerJobsProvider.notifier).fetchAll(),
            color: theme.primaryColor,
            child: Column(
              children: [
                if (isJobSelected) 
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: _buildJobHeader(),
                  )
                else
                  _buildDefaultHeader(),
                  
                _buildTabSection(tabCounts),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildUpgradeSection()),
                      SliverToBoxAdapter(child: _buildTopFilterSection()),
                      if (filteredApps.isEmpty)
                        SliverFillRemaining(child: _buildEmptyState())
                      else
                        _buildSliverList(filteredApps),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      color: theme.cardColor,
      child: Text(
        'Manage and review all job applications',
        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildJobHeader() {
    final job = _selectedJob;
    final location = job?['location'] ?? 'Location N/A';
    final salary = "₹${job?['salary_min'] ?? '0'} - ₹${job?['salary_max'] ?? '0'}";
    final exp = "${job?['experience'] ?? 'Any'} Exp";
    final education = job?['education'] ?? 'Any Education';
    
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildHeaderInfo(LucideIcons.mapPin, location),
            _buildHeaderDivider(),
            _buildHeaderInfo(LucideIcons.indianRupee, salary),
            _buildHeaderDivider(),
            _buildHeaderInfo(LucideIcons.graduationCap, education),
            _buildHeaderDivider(),
            _buildHeaderInfo(LucideIcons.history, exp),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(width: 4, height: 4, decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), shape: BoxShape.circle)),
    );
  }

  Widget _buildFilterDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Filters',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ],
              ),
            ),

            // Filter Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                children: [
                  _buildFilterSection('Location', Column(
                    children: [
                      _buildModernTextField('City, State...', LucideIcons.mapPin, (val) => _filterLocation = val),
                    ],
                  )),
                  _buildFilterSection('Distance', Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [5, 10, 25, 50].map((d) => _buildModernChip('$d km', _filterDistance == d, (selected) {
                      setState(() => _filterDistance = selected ? d : null);
                    })).toList(),
                  )),
                  _buildFilterSection('Experience', Row(
                    children: [
                      Expanded(child: _buildModernTextField('Min Yrs', LucideIcons.briefcase, (val) => _filterMinExp = double.tryParse(val))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModernTextField('Max Yrs', LucideIcons.briefcase, (val) => _filterMaxExp = double.tryParse(val))),
                    ],
                  )),
                  _buildFilterSection('Active In', Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [1, 3, 7, 14, 30].map((d) => _buildModernChip('Last $d Day${d > 1 ? 's' : ''}', _filterActiveIn == d, (selected) {
                      setState(() => _filterActiveIn = selected ? d : null);
                    })).toList(),
                  )),
                  _buildFilterSection('Matching Skills', Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ['Communication', 'Sales', 'Marketing', 'Java', 'Python', 'Leadership'].map((s) => _buildModernChip(s, _filterSkills.contains(s), (selected) {
                      setState(() {
                        if (selected) _filterSkills.add(s);
                        else _filterSkills.remove(s);
                      });
                    })).toList(),
                  )),
                  _buildFilterSection('English Fluency', Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ['Any', 'Good', 'Fluent'].map((f) => _buildModernChip(f, _filterEnglishFluency == f, (selected) {
                      if (selected) setState(() => _filterEnglishFluency = f);
                    })).toList(),
                  )),
                ],
              ),
            ),

            // Sticky Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: theme.brightness == Brightness.light ? [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4)),
                ] : [],
              ),
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchApplications();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.sliders, size: 18),
                      SizedBox(width: 10),
                      Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.2)),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 32),
        Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildModernTextField(String hint, IconData icon, Function(String) onChanged) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ] : [],
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernChip(String label, bool isSelected, Function(bool) onSelected) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: theme.cardColor,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      elevation: isSelected ? 4 : 0,
      shadowColor: AppColors.primary.withOpacity(0.2),
      showCheckmark: false,
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onSelected(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection(Map<String, int> tabCounts) {
    final bool isJobSelected = _selectedJob != null;
    
    if (isJobSelected) {
      return _buildJobStatsSection(tabCounts);
    }

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.cardColor,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          final count = tabCounts[_tabs[index]] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedTab = index);
                ref.read(navigationProvider.notifier).setApplicationsTabIndex(index);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : theme.dividerColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobStatsSection(Map<String, int> tabCounts) {
    final responses = tabCounts['All'] ?? 0;
    final hotLeads = tabCounts['Shortlist'] ?? 0;
    
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.cardColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Responses', responses.toString(), LucideIcons.messageSquare, AppColors.primary),
              const SizedBox(width: 12),
              _buildStatCard('Hot Leads', hotLeads.toString(), LucideIcons.zap, const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Database', '0', LucideIcons.database, const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildStatCard('Total Leads', responses.toString(), LucideIcons.users, const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
          boxShadow: theme.brightness == Brightness.light ? [
            BoxShadow(
              color: theme.colorScheme.onSurface.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                Text(
                  count,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          _buildSearchInput(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildFilterButton(
                  'Job: ${_selectedJob?['title'] ?? "All Jobs"}',
                  LucideIcons.briefcase,
                  () => _showJobPicker(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildFilterButton(
                  'Sort',
                  LucideIcons.arrowUpDown,
                  () => _showSortPicker(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1),
          boxShadow: theme.brightness == Brightness.light ? [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: theme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(LucideIcons.chevronDown, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchInput() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ] : [],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or skills...',
          hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                onPressed: () { _searchController.clear(); setState(() {}); },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUpgradeSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/subscription-plans');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF451A03).withOpacity(0.3) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFFD97706).withOpacity(0.2) : const Color(0xFFFEF3C7)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('Upgrade to unlock contact details', style: TextStyle(color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E), fontWeight: FontWeight.w700, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFD97706))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.users, size: 64, color: theme.dividerColor.withOpacity(0.1)),
        const SizedBox(height: 16),
        Text('No candidates found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildSliverList(List<dynamic> apps) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CandidateCard(
              app: apps[index],
              onTap: () => _showCandidatePreview(apps[index]),
            ),
          ),
          childCount: apps.length,
        ),
      ),
    );
  }

  void _showCandidatePreview(Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => _CandidatePreviewModal(app: app),
    );
  }

  void _showJobPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24),
        children: [
          Text('Select Job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          ListTile(
            title: Text('All Jobs', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
            onTap: () { setState(() => _selectedJob = null); _fetchApplications(); Navigator.pop(context); }
          ),
          ..._jobs.map((j) => ListTile(
            title: Text(j['title'], style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
            onTap: () { setState(() => _selectedJob = j); _fetchApplications(); Navigator.pop(context); }
          )),
        ],
      ),
    );
  }

  void _showSortPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Newest Applied', 'Best Match', 'Status'].map((opt) => ListTile(
          title: Text(opt, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
          onTap: () => Navigator.pop(context)
        )).toList(),
      ),
    );
  }
}

class _CandidateCard extends ConsumerWidget {
  final Map<String, dynamic> app;
  final VoidCallback onTap;

  const _CandidateCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: CANDIDATE CARD JSON => ${jsonEncode(app)}');
    final candidate = app['candidate'] ?? {};
    final job = app['job'] ?? {};
    final phone = candidate['phone'] ?? candidate['mobile'] ?? app['candidate_mobile'];
    final candId = candidate['id'] ?? app['candidate_id'];
    
    final name = candidate['full_name'] ?? app['full_name'] ?? "Candidate";
    final match = app['score']?.toString() ?? "0";
    
    // Build location dynamically: city + state + country
    final city = candidate['city']?.toString() ?? '';
    final state = candidate['state']?.toString() ?? '';
    final country = candidate['country']?.toString() ?? '';
    
    String location = "Not provided";
    List<String> locParts = [];
    if (city.isNotEmpty) locParts.add(city);
    if (state.isNotEmpty) locParts.add(state);
    if (country.isNotEmpty) locParts.add(country);
    if (locParts.isNotEmpty) location = locParts.join(', ');

    final experience = "${candidate['experience'] ?? '0'} Yrs";
    final jobTitle = job['title'] ?? app['job_title'] ?? 'Job';
    
    String? imageUrl = candidate['profile_image'] ?? app['profile_picture'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = "https://www.mindwareinfotech.com$imageUrl";
    }

    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: theme.brightness == Brightness.light ? [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
          ] : [],
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipOval(
                    child: imageUrl != null 
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.dividerColor.withOpacity(0.05),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.dividerColor.withOpacity(0.05),
                            child: Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor))),
                          ),
                        )
                      : Container(
                          color: theme.dividerColor.withOpacity(0.05),
                          child: Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: theme.primaryColor))),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.light ? const Color(0xFFF0FDF4) : const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text('$match%', style: TextStyle(color: theme.brightness == Brightness.light ? const Color(0xFF10B981) : const Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      Text(jobTitle, style: TextStyle(fontSize: 13, color: theme.primaryColor, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text("$experience Experience • $location", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.05)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAction(
                  context, 
                  FontAwesomeIcons.whatsapp, 
                  'WhatsApp', 
                  const Color(0xFF22C55E),
                  () => _handleWhatsApp(context, phone)
                ),
                const SizedBox(width: 8),
                _buildAction(
                  context, 
                  LucideIcons.phoneCall, 
                  'Call', 
                  const Color(0xFF4F46E5),
                  () => _handleCall(context, phone)
                ),
                const SizedBox(width: 8),
                _StageDropdown(app: app),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StageDropdown extends ConsumerWidget {
  final Map<String, dynamic> app;
  const _StageDropdown({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: CANDIDATE DETAILS JSON => ${jsonEncode(app['candidate'] ?? {})}');
    // Standardize mapping based on API response structure
    final status = app['status']?.toString().toLowerCase() ?? 'applied';
    
    // Normalize status to our keys
    String normalizedStatus = status;
    if (status == 'shortlisted' || status == 'shortlist') normalizedStatus = 'shortlisted';
    if (status == 'interviewed' || status == 'interviewing' || status == 'interview') normalizedStatus = 'interview';
    if (status == 'rejected' || status == 'reject') normalizedStatus = 'rejected';
    if (status == 'hired' || status == 'hire') normalizedStatus = 'hired';
    if (status == 'applied' || status == 'new' || status == 'pending' || status == 'fresh') normalizedStatus = 'new';
    if (status == 'contacting') normalizedStatus = 'contacting';

    final stages = [
      {'label': 'New', 'key': 'new', 'color': Colors.grey},
      {'label': 'Interview', 'key': 'interview', 'color': Colors.orange},
      {'label': 'Shortlisted', 'key': 'shortlisted', 'color': Colors.blue},
      {'label': 'Contacting', 'key': 'contacting', 'color': Colors.purple},
      {'label': 'Hired', 'key': 'hired', 'color': Colors.green},
      {'label': 'Rejected', 'key': 'rejected', 'color': Colors.red},
    ];

    final currentStage = stages.firstWhere(
      (s) => s['key'] == normalizedStatus,
      orElse: () => stages[0]
    );

    final stageColor = currentStage['color'] as Color;

    return PopupMenuButton<String>(
      onSelected: (newKey) async {
         print('Selected Status: $newKey');
         
         // Point 4: Removed optimistic update for better sync reliability
         // app['status'] = newKey; 

         // Show a small snackbar or loading indicator
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Updating stage to ${newKey.toUpperCase()}...'), 
             duration: const Duration(milliseconds: 500),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ),
         );
         
         await ref.read(employerJobsProvider.notifier).updateApplicationStatus(
           applicationId: app['application_id'] ?? app['id'],
           status: newKey,
           candidateId: app['candidate_id'] ?? app['candidate']?['id'],
           jobId: app['job_id'] ?? app['job']?['id'],
         );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => stages.map((s) => PopupMenuItem<String>(
        value: s['key'] as String,
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: s['color'] as Color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(s['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
          ],
        ),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: stageColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stageColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStage['label'] as String,
              style: TextStyle(color: stageColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronDown, size: 12, color: stageColor),
          ],
        ),
      ),
    );
  }
}

  void _handleWhatsApp(BuildContext context, dynamic phone) async {
    if (phone == null || phone.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp number not available')));
      return;
    }
    String cleanPhone = phone.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) cleanPhone = '91$cleanPhone';
    final url = Uri.parse("whatsapp://send?phone=$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed')));
    }
  }

  void _handleCall(BuildContext context, dynamic phone) async {
    if (phone == null || phone.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available')));
      return;
    }
    final url = Uri.parse("tel:${phone.toString()}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
    }
  }

  Widget _buildAction(BuildContext context, IconData icon, String label, Color bgColor, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label, 
                  style: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: 0.3
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

class _CandidatePreviewModal extends StatelessWidget {
  final Map<String, dynamic> app;
  const _CandidatePreviewModal({required this.app});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final candidate = app['candidate'] ?? {};
    final name = candidate['full_name'] ?? app['full_name'] ?? "Candidate";
    
    // Build location dynamically: city + state + country
    final city = candidate['city']?.toString() ?? '';
    final state = candidate['state']?.toString() ?? '';
    final country = candidate['country']?.toString() ?? '';
    
    String location = "Not provided";
    List<String> locParts = [];
    if (city.isNotEmpty) locParts.add(city);
    if (state.isNotEmpty) locParts.add(state);
    if (country.isNotEmpty) locParts.add(country);
    if (locParts.isNotEmpty) location = locParts.join(', ');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 32),
          _buildDetailRow(context, LucideIcons.mail, 'Email', candidate['email'] ?? 'Not provided'),
          _buildDetailRow(context, LucideIcons.phone, 'Phone', candidate['phone'] ?? 'Not provided'),
          _buildDetailRow(context, LucideIcons.mapPin, 'Location', location),
          _buildDetailRow(context, LucideIcons.briefcase, 'Experience', "${candidate['experience'] ?? '0'} Years"),
          const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailsScreen(candidate: app)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('View Full Application', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w700)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
