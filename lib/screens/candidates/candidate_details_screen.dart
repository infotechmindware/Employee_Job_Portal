import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class CandidateDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;
  
  const CandidateDetailsScreen({super.key, required this.candidate});

  String _val(dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == "null") return 'Not provided';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
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
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildHeader(String name, String jobTitle, String status, String? imageUrl) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFEEF2FF),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 32)) : null,
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

  Widget _buildBottomActions() {
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
              onPressed: () {},
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
              onPressed: () {},
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
