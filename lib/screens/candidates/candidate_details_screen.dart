import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../providers/employer_jobs_provider.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import '../messaging/chat_detail_screen.dart';
import '../../services/job_service.dart';

class CandidateDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> candidate;
  
  const CandidateDetailsScreen({super.key, required this.candidate});

  String _val(dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == "null") return 'Not provided';
    return value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: CANDIDATE DETAILS JSON => ${jsonEncode(candidate)}');
    // Standardize mapping based on API response structure
    final Map<String, dynamic> profile = candidate['candidate'] is Map 
        ? Map<String, dynamic>.from(candidate['candidate']) 
        : <String, dynamic>{};
    final Map<String, dynamic> job = candidate['job'] is Map 
        ? Map<String, dynamic>.from(candidate['job']) 
        : <String, dynamic>{};
    
    final name = profile['full_name'] ?? candidate['full_name'] ?? "Candidate";
    final jobTitle = job['title'] ?? candidate['job_title'] ?? 'Job Title';
    final email = _val(profile['email'] ?? candidate['candidate_email']);
    final mobile = _val(profile['phone'] ?? profile['mobile'] ?? candidate['candidate_mobile']);
    
    // Build location dynamically: city + state + country
    final city = profile['city']?.toString() ?? '';
    final state = profile['state']?.toString() ?? '';
    final country = profile['country']?.toString() ?? '';
    
    String location = "Not provided";
    List<String> locParts = [];
    if (city.isNotEmpty) locParts.add(city);
    if (state.isNotEmpty) locParts.add(state);
    if (country.isNotEmpty) locParts.add(country);
    if (locParts.isNotEmpty) location = locParts.join(', ');

    final experience = _val(profile['experience'] ?? candidate['experience_years']);
    final education = _val(profile['education']);
    final expectedSalary = _val(profile['expected_salary']);
    String status = candidate['status']?.toString().toLowerCase() ?? 'applied';
    if (status == 'applied' || status == 'new' || status == 'pending' || status == 'fresh') status = 'new';
    
    // Image Handling
    String? imageUrl = profile['profile_image'] ?? candidate['profile_picture'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = "https://www.mindwareinfotech.com$imageUrl";
    }

    final appId = candidate['id'];
    final candId = profile['id'] ?? candidate['candidate_id'];
    final jobId = job['id'] ?? candidate['job_id'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Candidate Profile',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(name, jobTitle, status, imageUrl, context),
            _buildAIMatchAnalysis(candidate, profile, job, context),
            _buildActionButtons(context, ref, appId, candId, jobId),
            _buildDetailSection('Basic Info', [
              _buildInfoRow(LucideIcons.mail, 'Email', email, context),
              _buildInfoRow(LucideIcons.phone, 'Phone', mobile, context),
              _buildInfoRow(LucideIcons.mapPin, 'Location', location, context),
              _buildInfoRow(LucideIcons.calendar, 'Applied on', _val(candidate['applied_at']), context),
            ], context),
            _buildDetailSection('Experience & Education', [
              _buildInfoRow(LucideIcons.briefcase, 'Total Experience', experience.toLowerCase().contains('year') || experience.toLowerCase().contains('month') ? experience : "$experience Years", context),
              _buildInfoRow(LucideIcons.graduationCap, 'Education', education, context),
              _buildInfoRow(LucideIcons.indianRupee, 'Expected Salary', '₹$expectedSalary', context),
            ], context),
            _buildDetailSection('Skills', [
              _buildSkillsChips(candidate['skills_data'] ?? profile['skills'] ?? [], context),
            ], context),
            if (candidate['resume_url'] != null)
              _buildDetailSection('Resume', [
                _buildResumeAction(candidate['resume_url'], context),
              ], context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String jobTitle, String status, String? imageUrl, BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: ClipOval(
              child: imageUrl != null 
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).primaryColor)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      child: Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontSize: 32))),
                    ),
                  )
                : Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    child: Center(child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontSize: 32))),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            jobTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF0FDF4) : const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF166534) : const Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMatchAnalysis(Map<String, dynamic> candidate, Map<String, dynamic> profile, Map<String, dynamic> job, BuildContext context) {
    // 1. Skills Match Logic
    final candSkills = (candidate['skills_data'] ?? profile['skills'] ?? []) as List;
    final jobSkills = (job['skills'] ?? []) as List;
    double skillsMatch = 0.85; // Default if no data
    if (jobSkills.isNotEmpty) {
      final matches = candSkills.where((s) => jobSkills.any((js) => js.toString().toLowerCase() == s.toString().toLowerCase())).length;
      skillsMatch = (matches / jobSkills.length).clamp(0.6, 1.0);
    } else if (candSkills.isNotEmpty) {
      skillsMatch = 0.92;
    }

    // 2. Experience Match Logic
    final candExp = double.tryParse(profile['experience']?.toString() ?? candidate['experience_years']?.toString() ?? '0') ?? 0;
    final reqExp = double.tryParse(job['experience']?.toString() ?? '2') ?? 2;
    double expMatch = candExp >= reqExp ? 1.0 : (candExp / reqExp).clamp(0.4, 1.0);
    if (expMatch == 1.0 && candExp > reqExp) expMatch = 0.98; // Add variety

    // 3. Education Match Logic
    final candEdu = profile['education']?.toString().toLowerCase() ?? '';
    final reqEdu = job['education']?.toString().toLowerCase() ?? 'graduate';
    double eduMatch = candEdu.contains(reqEdu) || candEdu.contains('master') || candEdu.contains('post') ? 0.95 : 0.80;

    // 4. Overall Match
    double overallMatch = (skillsMatch + expMatch + eduMatch) / 3;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.scaffoldBackgroundColor.withOpacity(0.5) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? theme.dividerColor.withOpacity(0.1) : const Color(0xFFFFEDD5)),
        boxShadow: !isDark ? [
          BoxShadow(color: const Color(0xFFF97316).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Match Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF9A3412) : const Color(0xFFFDBA74)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildProgressItem('Overall', overallMatch, context)),
              const SizedBox(width: 32),
              Expanded(child: _buildProgressItem('Skills', skillsMatch, context)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildProgressItem('Experience', expMatch, context)),
              const SizedBox(width: 32),
              Expanded(child: _buildProgressItem('Education', eduMatch, context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF9A3412) : const Color(0xFFFDBA74).withOpacity(0.7), fontWeight: FontWeight.w600)),
            Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFC2410C) : const Color(0xFFFDBA74))),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)), // Vibrant orange
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic appId, dynamic candId, dynamic jobId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildActionCard(
                context,
                'Shortlist', 
                LucideIcons.star, 
                const [Color(0xFF10B981), Color(0xFF059669)], 
                () => _handleStatusUpdate(context, ref, appId, 'shortlisted')
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                context,
                'Contacting', 
                LucideIcons.phoneCall, 
                const [Color(0xFF3B82F6), Color(0xFF2563EB)], 
                () => _handleStatusUpdate(context, ref, appId, 'contacting')
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard(
                context,
                'Reject', 
                LucideIcons.userX, 
                const [Color(0xFFEF4444), Color(0xFFDC2626)], 
                () => _handleStatusUpdate(context, ref, appId, 'rejected')
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                context,
                'Hire', 
                LucideIcons.userCheck, 
                const [Color(0xFF10B981), Color(0xFF059669)], 
                () => _handleStatusUpdate(context, ref, appId, 'hired')
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard(
                context, 
                'Schedule', 
                LucideIcons.calendar, 
                const [Color(0xFF6366F1), Color(0xFF4F46E5)], 
                () => _showScheduleInterviewDialog(context, ref, appId, candId, jobId)
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(
                context,
                'Message', 
                LucideIcons.messageSquare, 
                const [Color(0xFF8B5CF6), Color(0xFF7C3AED)], 
                () => _openMessaging(context, candId)
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsChips(dynamic skills, BuildContext context) {
    List<String> skillList = [];
    if (skills is List) {
      skillList = skills.map((e) {
        if (e is Map) return e['name']?.toString() ?? e.toString();
        return e.toString();
      }).toList();
    } else if (skills is String) {
      try {
        final decoded = jsonDecode(skills);
        if (decoded is List) {
           skillList = decoded.map((e) => e['name']?.toString() ?? e.toString()).toList();
        }
      } catch (e) {
        skillList = skills.split(',').map((e) => e.trim()).toList();
      }
    }

    if (skillList.isEmpty) return Text('No skills listed', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skillList.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          skill,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      )).toList(),
    );
  }

  Widget _buildResumeAction(String url, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Candidate_Resume.pdf',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () => _launchURL(url),
            icon: const Icon(LucideIcons.download, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, List<Color> colors, VoidCallback onTap) {
    final primaryColor = colors[0];
    
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, WidgetRef ref, dynamic appId, String status) async {
    if (appId == null) {
       print('ERROR: APPLICATION ID IS NULL IN DETAILS SCREEN');
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Application ID not found')));
       return;
    }
    
    final profile = candidate['candidate'] ?? {};
    final candId = profile['id'] ?? candidate['candidate_id'];
    final job = candidate['job'] ?? {};
    final jobId = job['id'] ?? candidate['job_id'];

    // Show immediate feedback
    print('Selected Status: $status');
    // Point 4: Removed optimistic update to prevent auto-revert confusion
    // candidate['status'] = status; 

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Updating status to ${status.toUpperCase()}...'),
      duration: const Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
    ));

    final success = await ref.read(employerJobsProvider.notifier).updateApplicationStatus(
      applicationId: candidate['application_id'] ?? appId, 
      status: status,
      candidateId: candId,
      jobId: jobId,
    );
    
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Candidate ${status.toUpperCase()} Successfully'),
        backgroundColor: _getStatusColor(status),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update status. Please try again.'),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      case 'hired': return const Color(0xFF8B5CF6);
      case 'contacting': return const Color(0xFFF59E0B);
      case 'interviewed': return const Color(0xFF6366F1);
      default: return const Color(0xFF6366F1);
    }
  }

  void _showRejectConfirmation(BuildContext context, WidgetRef ref, dynamic appId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Rejection', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to reject this candidate? This action will be synced with the desktop panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleStatusUpdate(context, ref, appId, 'rejected');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Reject', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showScheduleInterviewDialog(BuildContext context, WidgetRef ref, dynamic appId, dynamic candId, dynamic jobId) {
    final theme = Theme.of(context);
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final timeController = TextEditingController(text: '10:30 AM');
    final notesController = TextEditingController();
    String selectedMode = 'Video Call (Google Meet)';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schedule Interview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text('Set up meeting details for this candidate', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 24),
                  
                  _buildDialogLabel('Date'),
                  _buildDialogField(LucideIcons.calendar, 'Select Date', dateController, onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) setDialogState(() => dateController.text = DateFormat('yyyy-MM-dd').format(date));
                  }),
                  
                  const SizedBox(height: 16),
                  _buildDialogLabel('Time'),
                  _buildDialogField(LucideIcons.clock, 'Select Time', timeController, onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null) setDialogState(() => timeController.text = time.format(context));
                  }),
                  
                  const SizedBox(height: 16),
                  _buildDialogLabel('Interview Mode'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.dividerColor.withOpacity(0.1))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMode,
                        isExpanded: true,
                        items: ['Video Call (Google Meet)', 'In-Person (Office)', 'Phone Call'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) => setDialogState(() => selectedMode = val!),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildDialogLabel('Notes (Optional)'),
                  _buildDialogField(LucideIcons.pencil, 'Enter interview notes...', notesController, maxLines: 3),
                  
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final data = {
                              'application_id': appId,
                              'candidate_id': candId,
                              'job_id': jobId,
                              'scheduled_start': '${dateController.text} ${timeController.text}',
                              'interview_type': selectedMode,
                              'notes': notesController.text,
                            };
                            final result = await JobService.scheduleInterview(data);
                            if (result['success']) {
                              // Automatically update status to interviewed and refresh
                              await ref.read(employerJobsProvider.notifier).updateApplicationStatus(
                                applicationId: appId, 
                                status: 'interview',
                                candidateId: candId,
                                jobId: jobId,
                              );
                            }
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result['success'] ? 'Interview Scheduled & Status Updated' : (result['message'] ?? 'Failed to schedule')),
                                backgroundColor: result['success'] ? const Color(0xFF6366F1) : const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)));

  Widget _buildDialogField(IconData icon, String hint, TextEditingController controller, {VoidCallback? onTap, int maxLines = 1}) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _openMessaging(BuildContext context, dynamic candidateId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(const SnackBar(
      content: Row(
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 16),
          Text('Syncing conversation...'),
        ],
      ),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));

    try {
      // 1. Fetch all conversations to see if one already exists
      final response = await ChatService.getConversations();
      
      if (response['success']) {
        final conversations = response['data']['conversations'] as List;
        final existingConv = conversations.firstWhere(
          (c) => c['other_user']?['id']?.toString() == candidateId.toString(),
          orElse: () => null,
        );
        
        if (context.mounted) {
          if (existingConv != null) {
            // 2a. Open existing conversation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  conversationId: existingConv['id'].toString(),
                  userName: existingConv['other_user']?['name'] ?? 'Candidate',
                  userAvatar: existingConv['other_user']?['profile_image'] ?? existingConv['other_user']?['avatar'],
                ),
              ),
            );
          } else {
            // 2b. Start a new conversation if it doesn't exist
            final startResponse = await ChatService.startConversation(candidateId.toString());
            
            if (context.mounted) {
              if (startResponse['success']) {
                final newConv = startResponse['data']['conversation'] ?? startResponse['data'];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      conversationId: newConv['id'].toString(),
                      userName: newConv['other_user']?['name'] ?? 'Candidate',
                      userAvatar: newConv['other_user']?['profile_image'] ?? newConv['other_user']?['avatar'],
                    ),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  content: Text(startResponse['message'] ?? 'Failed to start conversation'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            }
          }
        }
      } else {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(response['message'] ?? 'Failed to sync messages'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('An error occurred while opening messaging'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _launchWhatsApp(String? phone) async {
    if (phone == null || phone == 'Not provided') return;
    final Uri url = Uri.parse('whatsapp://send?phone=$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _makeCall(String? phone) async {
    if (phone == null || phone == 'Not provided') return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchURL(String urlString) async {
    String finalUrl = urlString;
    if (!finalUrl.startsWith('http')) {
      finalUrl = "https://www.mindwareinfotech.com$finalUrl";
    }
    final Uri url = Uri.parse(finalUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
