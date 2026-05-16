import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'candidate_details_screen.dart';
import '../../providers/employer_jobs_provider.dart';
import '../../theme/app_colors.dart';

class CandidatesScreen extends ConsumerStatefulWidget {
  final String? jobId;
  final int initialTab;
  
  const CandidatesScreen({super.key, this.jobId, this.initialTab = 0});

  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  static const List<String> _tabsData = [
    'All',
    'New',
    'Shortlisted',
    'Interviewed',
    'Rejected',
    'Hired',
  ];

  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final stateAsync = ref.watch(employerJobsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: widget.jobId != null ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: Text(
          widget.jobId != null ? 'Job Applications' : 'All Candidates',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: stateAsync.when(
        data: (state) {
          var apps = state.applications;
          
          // Filter by Job ID
          if (widget.jobId != null) {
            apps = apps.where((a) => a['job_id']?.toString() == widget.jobId).toList();
          }

          // Filter by Tab
          if (_selectedTab > 0) {
            final filterStatus = _tabsData[_selectedTab].toLowerCase();
            apps = apps.where((a) {
              final status = a['status']?.toString().toLowerCase() ?? 'applied';
              if (filterStatus == 'new') return status == 'applied' || status == 'new' || status == 'fresh' || status == 'pending';
              if (filterStatus == 'interviewed' || filterStatus == 'interview') return status == 'interviewed' || status == 'interviewing' || status == 'interview';
              if (filterStatus == 'shortlisted' || filterStatus == 'shortlist') return status == 'shortlisted' || status == 'shortlist';
              return status == filterStatus;
            }).toList();
          }

          // Filter by Search (Case-insensitive & Real-time)
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            apps = apps.where((a) {
              final candidate = a['candidate'] ?? {};
              final name = (candidate['full_name'] ?? a['candidate_name'] ?? '').toString().toLowerCase();
              final email = (candidate['email'] ?? a['candidate_email'] ?? '').toString().toLowerCase();
              final phone = (candidate['phone'] ?? candidate['mobile'] ?? a['candidate_mobile'] ?? '').toString().toLowerCase();
              
              // Skills search handling
              String skillsStr = "";
              final rawSkills = a['skills_data'] ?? candidate['skills'] ?? candidate['skills_data'] ?? [];
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCards(state.applications),
                const SizedBox(height: 24),
                _buildSearchAndFilter(),
                const SizedBox(height: 24),
                _buildCandidateList(apps, isDesktop),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusCards(List<dynamic> allApps) {
    // If a jobId is provided, only count apps for that job
    final relevantApps = widget.jobId != null 
        ? allApps.where((a) => a['job_id']?.toString() == widget.jobId).toList()
        : allApps;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabsData.length, (index) {
          final isSelected = _selectedTab == index;
          
          // Calculate count for this tab
          int count = 0;
          if (index == 0) {
            count = relevantApps.length;
          } else {
            final filterStatus = _tabsData[index].toLowerCase();
            count = relevantApps.where((a) {
              final status = a['status']?.toString().toLowerCase() ?? 'applied';
              if (filterStatus == 'new') return status == 'applied' || status == 'new' || status == 'fresh' || status == 'pending';
              if (filterStatus == 'interviewed' || filterStatus == 'interview') return status == 'interviewed' || status == 'interviewing' || status == 'interview';
              if (filterStatus == 'shortlisted' || filterStatus == 'shortlist') return status == 'shortlisted' || status == 'shortlist';
              return status == filterStatus;
            }).length;
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Text(
                    _tabsData[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : Theme.of(context).dividerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search by candidate name...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCandidateList(List<dynamic> apps, bool isDesktop) {
    if (apps.isEmpty) return _buildEmptyState();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 180,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _CandidateCard(
          app: app,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CandidateDetailsScreen(candidate: app)),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(LucideIcons.users, size: 64, color: Theme.of(context).dividerColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('No candidates found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Try changing filters or search query', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final Map<String, dynamic> app;
  final VoidCallback onTap;

  const _CandidateCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = app['status']?.toString().toUpperCase() ?? 'NEW';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          boxShadow: Theme.of(context).brightness == Brightness.light ? [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'candidate_${app['id']}',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: app['candidate']?['profile_image'] != null 
                      ? NetworkImage("https://www.mindwareinfotech.com${app['candidate']['profile_image']}") 
                      : null,
                    child: app['candidate']?['profile_image'] == null 
                      ? Text((app['candidate']?['full_name'] ?? 'C')[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)) 
                      : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['candidate']?['full_name'] ?? app['candidate_name'] ?? 'Unknown',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        [
                          app['candidate']?['city'],
                          app['candidate']?['state'],
                          app['candidate']?['country']
                        ].where((e) => e != null && e.toString().isNotEmpty).join(', ').isEmpty 
                          ? 'Location not specified' 
                          : [
                              app['candidate']?['city'],
                              app['candidate']?['state'],
                              app['candidate']?['country']
                            ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF0FDF4) : const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF166534) : const Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.05)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied ${app['applied_at'] ?? 'Just now'}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                ),
                const Text(
                  'View Details →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
