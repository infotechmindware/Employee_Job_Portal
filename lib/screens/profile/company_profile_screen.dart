import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/common/image_upload_card.dart';
import '../../theme/app_colors.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  String? _selectedCompanySize;

  final List<String> _companySizes = [
    '1-10 employees',
    '11-50 employees',
    '51-200 employees',
    '201-500 employees',
    '501-1000 employees',
    '1000+ employees'
  ];
  final List<TextEditingController> _whyJoinControllers = [
    TextEditingController(text: 'Flexible working hours'),
    TextEditingController(text: 'Competitive salary'),
  ];

  void _addPoint() {
    setState(() => _whyJoinControllers.add(TextEditingController()));
  }

  void _removePoint(int index) {
    if (_whyJoinControllers.length > 1) {
      setState(() {
        _whyJoinControllers[index].dispose();
        _whyJoinControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _whyJoinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 32),
            _buildStatsGrid(isDesktop),
            const SizedBox(height: 40),
            _buildCompanyForm(isDesktop),
            const SizedBox(height: 32),
            _buildWhyJoinUs(isDesktop),
            const SizedBox(height: 32),
            _buildMediaSection(isDesktop),
            const SizedBox(height: 32),
            _buildEmptyStatesGrid(isDesktop),
            const SizedBox(height: 48),
            _buildActionButtons(isDesktop),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage your public brand and company details',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    final stats = [
      {'label': 'Total Reviews', 'value': '124', 'icon': LucideIcons.star, 'color': Color(0xFFF59E0B)},
      {'label': 'Avg. Rating', 'value': '4.8', 'icon': LucideIcons.award, 'color': Color(0xFF6366F1)},
      {'label': 'Followers', 'value': '1.2k', 'icon': LucideIcons.users, 'color': Color(0xFF10B981)},
      {'label': 'Blogs', 'value': '12', 'icon': LucideIcons.bookOpen, 'color': Color(0xFFEC4899)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 110,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(stat['icon'] as IconData, size: 16, color: stat['color'] as Color),
                  const SizedBox(width: 8),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyForm(bool isDesktop) {
    return _buildFormCard(
      title: 'Business Details',
      icon: LucideIcons.building,
      children: [
        _buildResponsiveFields(isDesktop, [
          _buildField('Legal Company Name', 'Mindware info tech sd'),
          _buildField('Corporate Website', 'https://mindware.com'),
        ]),
        const SizedBox(height: 20),
        _buildResponsiveFields(isDesktop, [
          _buildField('Headquarters', 'Silicon Valley, CA'),
          _buildField('Founded Year', '2015'),
        ]),
        const SizedBox(height: 20),
        _buildResponsiveFields(isDesktop, [
          _buildDropdown(
            'Company Size',
            _selectedCompanySize,
            'Select size',
            _companySizes,
            (val) => setState(() => _selectedCompanySize = val),
          ),
          _buildField('Annual Revenue', '\$5M - \$10M'),
        ]),
        const SizedBox(height: 20),
        _buildField('About Company', 'Describe your company mission and vision...', maxLines: 5),
      ],
    );
  }

  Widget _buildWhyJoinUs(bool isDesktop) {
    return _buildFormCard(
      title: 'Why Join Points',
      icon: LucideIcons.heart,
      headerAction: ElevatedButton(
        onPressed: _addPoint,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text('Add Point', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
      children: [
        const Text(
          'Highlight the key benefits and culture points that attract top talent.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
        ),
        const SizedBox(height: 20),
        ...List.generate(_whyJoinControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _whyJoinControllers[index],
                    decoration: InputDecoration(
                      hintText: 'e.g., Great work-life balance',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
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
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => _removePoint(index),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: const Text('Remove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }


  Widget _buildMediaSection(bool isDesktop) {
    return _buildFormCard(
      title: 'Brand Assets',
      icon: LucideIcons.image,
      children: [
        _buildResponsiveFields(isDesktop, [
          _buildField('CEO Name', 'Sanjay Kumar'),
          ImageUploadCard(
            label: 'CEO Photo',
            subLabel: 'Click to upload portrait',
            onImageSelected: (file) {},
          ),
        ]),
        const SizedBox(height: 24),
        _buildResponsiveFields(isDesktop, [
          ImageUploadCard(
            label: 'Company Logo',
            subLabel: '1:1 Ratio (PNG/SVG)',
            onImageSelected: (file) {},
          ),
          ImageUploadCard(
            label: 'Brand Banner',
            subLabel: '16:9 Aspect Ratio',
            onImageSelected: (file) {},
          ),
        ]),
      ],
    );
  }

  Widget _buildEmptyStatesGrid(bool isDesktop) {
    return _buildResponsiveFields(isDesktop, [
      _buildEmptySection('Recent Jobs', LucideIcons.briefcase, 'Post a new job to start hiring.'),
      _buildEmptySection('Company Blogs', LucideIcons.penTool, 'Share your thoughts and updates.'),
    ]);
  }

  Widget _buildEmptySection(String title, IconData icon, String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const Spacer(),
              const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 24),
          Icon(icon, size: 32, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? headerAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
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
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, String placeholder, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                placeholder,
                style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              icon: Container(
                margin: const EdgeInsets.only(right: 8),
                child: const Icon(LucideIcons.chevronDown, size: 18, color: Color(0xFF64748B)),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              items: items.map((v) => DropdownMenuItem(
                value: v,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    v,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildResponsiveFields(bool isDesktop, List<Widget> children) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList(),
      );
    }
    return Column(
      children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList(),
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            foregroundColor: const Color(0xFF64748B),
          ),
          child: const Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
