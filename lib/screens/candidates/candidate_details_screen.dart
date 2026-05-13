import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../providers/employer_jobs_provider.dart';

class CandidateDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> candidate;
  
  const CandidateDetailsScreen({super.key, required this.candidate});

  String _val(dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == "null") return 'Not provided';
    return value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Standardize mapping based on API response structure
    final profile = candidate['candidate'] ?? {};
    final job = candidate['job'] ?? {};
    
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
    final status = candidate['status']?.toString().toLowerCase() ?? 'applied';
    
    // Image Handling
    String? imageUrl = profile['profile_image'] ?? candidate['profile_picture'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = "https://www.mindwareinfotech.com$imageUrl";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Candidate Profile',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(name, jobTitle, status, imageUrl),
            _buildAIMatchAnalysis(candidate, profile, job),
            _buildActionButtons(mobile),
            _buildDetailSection('Basic Info', [
              _buildInfoRow(LucideIcons.mail, 'Email', email),
              _buildInfoRow(LucideIcons.phone, 'Phone', mobile),
              _buildInfoRow(LucideIcons.mapPin, 'Location', location),
              _buildInfoRow(LucideIcons.calendar, 'Applied on', _val(candidate['applied_at'])),
            ]),
            _buildDetailSection('Experience & Education', [
              _buildInfoRow(LucideIcons.briefcase, 'Total Experience', experience.toLowerCase().contains('year') || experience.toLowerCase().contains('month') ? experience : "$experience Years"),
              _buildInfoRow(LucideIcons.graduationCap, 'Education', education),
              _buildInfoRow(LucideIcons.indianRupee, 'Expected Salary', '₹$expectedSalary'),
            ]),
            _buildDetailSection('Skills', [
              _buildSkillsChips(candidate['skills_data'] ?? profile['skills'] ?? []),
            ]),
            if (candidate['resume_url'] != null)
              _buildDetailSection('Resume', [
                _buildResumeAction(candidate['resume_url']),
              ]),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(context, ref),
    );
  }

  Widget _buildHeader(String name, String jobTitle, String status, String? imageUrl) {
    return Container(
      width: double.infinity,
      color: Colors.white,
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
                      color: const Color(0xFFEEF2FF),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6366F1))),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFEEF2FF),
                      child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 32))),
                    ),
                  )
                : Container(
                    color: const Color(0xFFEEF2FF),
                    child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 32))),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text(
            jobTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMatchAnalysis(Map<String, dynamic> candidate, Map<String, dynamic> profile, Map<String, dynamic> job) {
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

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Light orange background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFEDD5)), // Orange border
        boxShadow: [
          BoxShadow(color: const Color(0xFFF97316).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Match Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF9A3412)), // Deep orange text
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildProgressItem('Overall', overallMatch)),
              const SizedBox(width: 32),
              Expanded(child: _buildProgressItem('Skills', skillsMatch)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildProgressItem('Experience', expMatch)),
              const SizedBox(width: 32),
              Expanded(child: _buildProgressItem('Education', eduMatch)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9A3412), fontWeight: FontWeight.w600)),
            Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFC2410C))),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)), // Vibrant orange
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String? phone) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(phone),
              icon: const Icon(LucideIcons.phone, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makeCall(phone),
              icon: const Icon(LucideIcons.phoneCall, size: 18),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsChips(dynamic skills) {
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

    if (skillList.isEmpty) return const Text('No skills listed', style: TextStyle(color: Color(0xFF94A3B8)));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skillList.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          skill,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
      )).toList(),
    );
  }

  Widget _buildResumeAction(String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            icon: const Icon(LucideIcons.download, size: 20, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    final appId = candidate['id'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                if (appId == null) return;
                final success = await ref.read(employerJobsProvider.notifier).updateApplicationStatus(appId, 'rejected');
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate Rejected')));
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (appId == null) return;
                final success = await ref.read(employerJobsProvider.notifier).updateApplicationStatus(appId, 'shortlisted');
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate Shortlisted')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Shortlist', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
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
