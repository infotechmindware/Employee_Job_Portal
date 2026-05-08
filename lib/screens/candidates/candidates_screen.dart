import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'candidate_details_screen.dart';
import '../../providers/employer_jobs_provider.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.jobId != null ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: Text(
          widget.jobId != null ? 'Job Applications' : 'All Candidates',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 18),
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
              if (filterStatus == 'new') return status == 'applied' || status == 'new';
              return status == filterStatus;
            }).toList();
          }

          // Filter by Search
          if (_searchQuery.isNotEmpty) {
            apps = apps.where((a) {
              final name = a['candidate_name']?.toString().toLowerCase() ?? '';
              return name.contains(_searchQuery.toLowerCase());
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
              if (filterStatus == 'new') return status == 'applied' || status == 'new';
              return status == filterStatus;
            }).length;
          }

          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Text(
                    _tabsData[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: 'Search by candidate name...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
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
            const Icon(LucideIcons.users, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text('No candidates found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Try changing filters or search query', style: TextStyle(color: Colors.grey.shade500)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
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
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: const Icon(LucideIcons.user, size: 24, color: Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['candidate_name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        app['location'] ?? 'Location not specified',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied ${app['applied_at'] ?? 'Just now'}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const Text(
                  'View Details →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
