import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final List<String> _whyJoinPoints = ['Flexible working hours', 'Competitive salary'];

  void _addPoint() {
    setState(() => _whyJoinPoints.add(''));
  }

  void _removePoint(int index) {
    setState(() => _whyJoinPoints.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            _buildStatsHeader(isDesktop),
            const SizedBox(height: 32),
            _buildCompanyInfoForm(isDesktop),
            const SizedBox(height: 32),
            _buildWhyJoinSection(isDesktop),
            const SizedBox(height: 32),
            _buildMediaSection(isDesktop),
            const SizedBox(height: 32),
            _buildActions(),
            const SizedBox(height: 48),
            _buildBottomSections(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(bool isDesktop) {
    final stats = [
      {'title': 'Total Reviews', 'value': '0', 'icon': LucideIcons.star, 'color': Colors.amber},
      {'title': 'Average Rating', 'value': '0.0 ⭐', 'icon': LucideIcons.thumbsUp, 'color': Colors.blue},
      {'title': 'Followers', 'value': '0', 'icon': LucideIcons.users, 'color': Colors.purple},
      {'title': 'Blogs Published', 'value': '0', 'icon': LucideIcons.bookOpen, 'color': Colors.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 100,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (stat['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(stat['icon'], size: 20, color: stat['color']),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat['title'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                Text(stat['value'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoForm(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(LucideIcons.building, 'Company Information'),
          const SizedBox(height: 24),
          _buildResponsiveRow(isDesktop, [
            _buildTextField('Company Name', 'Enter company name'),
            _buildTextField('Website', 'https://example.com'),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveRow(isDesktop, [
            _buildTextField('Headquarters', 'e.g. San Francisco, CA'),
            _buildTextField('Founded Year', 'e.g. 2010'),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveRow(isDesktop, [
            _buildDropdown('Company Size', 'Select Size'),
            _buildTextField('Revenue', 'e.g. \$1M - \$5M'),
          ]),
          const SizedBox(height: 16),
          _buildTextField('About Company', 'Describe your company...', maxLines: 5),
        ],
      ),
    );
  }

  Widget _buildWhyJoinSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(LucideIcons.heart, 'Why Join Us?'),
              TextButton.icon(
                onPressed: _addPoint,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add Point'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._whyJoinPoints.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildTextField('', 'Enter benefit...', initialValue: entry.value)),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removePoint(entry.key),
                      icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMediaSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(LucideIcons.image, 'Media & CEO'),
          const SizedBox(height: 24),
          _buildResponsiveRow(isDesktop, [
            _buildTextField('CEO Name', 'Enter CEO name'),
            _buildFileUpload('CEO Photo', 'Upload photo'),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveRow(isDesktop, [
            _buildFileUpload('Company Logo', 'Upload logo'),
            _buildFileUpload('Company Banner', 'Upload banner'),
          ]),
        ],
      ),
    );
  }

  Widget _buildBottomSections(bool isDesktop) {
    return Column(
      children: [
        _buildResponsiveRow(isDesktop, [
          _buildSectionCard('Jobs', LucideIcons.briefcase, 'No jobs published yet', 'New Job'),
          _buildSectionCard('Blogs', LucideIcons.book, 'No blogs published yet', 'New Blog'),
        ]),
        const SizedBox(height: 16),
        _buildResponsiveRow(isDesktop, [
          _buildSectionCard('Reviews', LucideIcons.star, 'No reviews yet', null),
          _buildSectionCard('Followers', LucideIcons.users, 'No followers yet', null),
        ]),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, String emptyMsg, String? btnText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              if (btnText != null)
                TextButton(onPressed: () {}, child: Text(btnText, style: const TextStyle(fontSize: 13, color: Color(0xFF6366F1)))),
            ],
          ),
          const SizedBox(height: 24),
          Icon(icon, size: 32, color: const Color(0xFF94A3B8).withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(emptyMsg, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () {}, child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1, String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
        ],
        TextField(
          maxLines: maxLines,
          controller: initialValue != null ? TextEditingController(text: initialValue) : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0)), color: Colors.white),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected == 'Select Size' ? null : selected,
              hint: Text(selected, style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              items: [],
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              const Icon(LucideIcons.upload, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveRow(bool isDesktop, List<Widget> children) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList(),
      );
    }
    return Column(
      children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
    );
  }
}
