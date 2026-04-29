import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class FilterSidebar extends StatefulWidget {
  const FilterSidebar({super.key});

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  // Track which section is currently expanded
  int _expandedIndex = -1; // Default to all collapsed

  // State for filter values
  String _distance = '10 km';
  String _activeIn = 'Last 7 Days';
  String _englishFluency = 'Any';
  final Map<String, bool> _skills = {
    'Communication': false,
    'Sales': false,
    'Marketing': false,
    'Java': false,
    'Python': false,
    'Leadership': false,
  };

  void _toggleSection(int index) {
    setState(() {
      _expandedIndex = (_expandedIndex == index) ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _distance = '10 km';
                      _activeIn = 'Last 7 Days';
                      _englishFluency = 'Any';
                      _skills.updateAll((key, value) => false);
                    });
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // Filter Sections
          _buildAccordionSection(
            index: 0,
            title: 'Location',
            child: _buildLocationSection(),
          ),
          _buildAccordionSection(
            index: 1,
            title: 'Experience',
            child: _buildExperienceSection(),
          ),
          _buildAccordionSection(
            index: 2,
            title: 'Active In',
            child: _buildActiveInSection(),
          ),
          _buildAccordionSection(
            index: 3,
            title: 'Matching Skills',
            child: _buildSkillsSection(),
          ),
          _buildAccordionSection(
            index: 4,
            title: 'English Fluency',
            child: _buildEnglishFluencySection(),
          ),

          // Fixed Bottom Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionSection({
    required int index,
    required String title,
    required Widget child,
  }) {
    final bool isExpanded = _expandedIndex == index;

    return Column(
      children: [
        InkWell(
          onTap: () => _toggleSection(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: const Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: child,
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(color: Color(0xFFF1F5F9), height: 1),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'City, State...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Distance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5)),
            Text('km', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 8),
        ...['5 km', '10 km', '25 km', '50 km'].map((dist) => _buildRadioItem(dist, _distance, (val) => setState(() => _distance = val!))),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Min (Years)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              TextField(
                decoration: _inputDecoration(),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Max (Years)', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              TextField(
                decoration: _inputDecoration(),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveInSection() {
    return Column(
      children: [
        'Last 1 Day',
        'Last 3 Days',
        'Last 7 Days',
        'Last 14 Days',
        'Last 30 Days'
      ].map((opt) => _buildRadioItem(opt, _activeIn, (val) => setState(() => _activeIn = val!))).toList(),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      children: _skills.keys.map((skill) {
        return InkWell(
          onTap: () => setState(() => _skills[skill] = !_skills[skill]!),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _skills[skill],
                    onChanged: (val) => setState(() => _skills[skill] = val!),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(skill, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnglishFluencySection() {
    return Column(
      children: ['Any', 'Good', 'Fluent']
          .map((opt) => _buildRadioItem(opt, _englishFluency, (val) => setState(() => _englishFluency = val!)))
          .toList(),
    );
  }

  Widget _buildRadioItem(String label, String groupValue, ValueChanged<String?> onChanged) {
    return InkWell(
      onTap: () => onChanged(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Radio<String>(
                value: label,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      fillColor: const Color(0xFFF8FAFC),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
