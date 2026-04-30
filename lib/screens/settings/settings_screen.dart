import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTabIndex = 0;

  // State for selections
  String _selectedIndustry = 'IT/Software';
  String _selectedCompanySize = '11-50 employees';
  String _selectedTimezone = 'Asia/Kolkata (IST)';

  final List<String> _industries = ['IT/Software', 'Healthcare', 'Finance', 'Education', 'E-commerce', 'Manufacturing', 'Marketing', 'Real Estate', 'Logistics', 'Other'];
  final List<String> _companySizes = ['1-10 employees', '11-50 employees', '51-200 employees', '201-500 employees', '501-1000 employees', '1000+ employees'];
  final List<String> _timezones = [
    'Asia/Kolkata (IST)', 'UTC (Coordinated Universal Time)', 'GMT (Greenwich Mean Time)', 'America/New_York (EST)', 
    'America/Los_Angeles (PST)', 'Europe/London (BST)', 'Europe/Paris (CEST)', 'Asia/Dubai (GST)', 'Asia/Singapore (SGT)', 'Australia/Sydney (AEST)'
  ];

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Account', 'icon': LucideIcons.user},
    {'title': 'Company', 'icon': LucideIcons.building},
    {'title': 'Notifications', 'icon': LucideIcons.bell},
    {'title': 'Preferences', 'icon': LucideIcons.settings},
    {'title': 'Security', 'icon': LucideIcons.lock},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? screenWidth * 0.08 : 16,
            vertical: isDesktop ? 32 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed Sidebar
                          SizedBox(
                            width: 180, // Compact fixed sidebar
                            child: _buildSidebar(isMobile),
                          ),
                          const SizedBox(width: 24),
                          // Scrollable Content area
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(), // No more "khichna" (stretching)
                              child: _buildContentArea(isDesktop, isMobile),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildMobileTabs(),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: _buildContentArea(isDesktop, isMobile),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 26, // Compact title
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Manage your account settings and preferences',
          style: TextStyle(
            fontSize: 12, // Compact subtitle
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTabIndex == entry.key;
          return _buildSidebarItem(entry.value['title'], entry.value['icon'], isSelected, () {
            setState(() => _selectedTabIndex = entry.key);
          });
        }).toList(),
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16, // Compact icon
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12, // Compact text
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTabIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tabs[index]['icon'],
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tabs[index]['title'],
                    style: TextStyle(
                      fontSize: 9, // Very compact font to fit all
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContentArea(bool isDesktop, bool isMobile) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(_selectedTabIndex),
        child: _buildContentPanel(isDesktop, isMobile),
      ),
    );
  }

  Widget _buildContentPanel(bool isDesktop, bool isMobile) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAccountSettings(isMobile);
      case 1:
        return _buildCompanyInformation(isMobile);
      case 2:
        return _buildNotificationPreferences(isMobile);
      case 3:
        return _buildPreferences(isMobile);
      case 4:
        return _buildSecuritySettings(isMobile);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountSettings(bool isMobile) {
    return _buildTabContainer(
      title: 'Account Settings',
      subtitle: 'Manage your primary account info',
      children: [
        _buildCompactField('Email Address', 'sujit2@gmail.com', helper: 'Primary contact address'),
        const SizedBox(height: 16),
        _buildCompactField('Phone Number', '+91 9334748028', helper: 'For account security'),
        const SizedBox(height: 24),
        _buildPhoneVerificationSection(),
        const SizedBox(height: 24),
        _buildAccountStatusSection(),
      ],
    );
  }

  Widget _buildPhoneVerificationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.alertCircle, size: 12, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              const Text('Not verified', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
              const Spacer(),
              _buildSmallButton('Send OTP', onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter OTP',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSmallButton('Verify', onPressed: () {}, isTransparent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            SizedBox(height: 2),
            Text('Not Verified', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
          ],
        ),
        _buildPrimaryButton('Save Changes', onPressed: () {}),
      ],
    );
  }

  Widget _buildCompanyInformation(bool isMobile) {
    return _buildTabContainer(
      title: 'Company Info',
      subtitle: 'Update your corporate details',
      children: [
        _buildCompactField('Company Name', 'Mindware info tech'),
        const SizedBox(height: 16),
        _buildCompactField('Website', 'https://web.whatsapp.com/'),
        const SizedBox(height: 16),
        _buildCompactField('Description', 'Innovation-driven software solutions provider focusing on enterprise excellence.', lines: 3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCompactDropdown('Industry', _selectedIndustry, _industries, (v) => setState(() => _selectedIndustry = v!))),
            const SizedBox(width: 12),
            Expanded(child: _buildCompactDropdown('Size', _selectedCompanySize, _companySizes, (v) => setState(() => _selectedCompanySize = v!))),
          ],
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _buildPrimaryButton('Update Info', onPressed: () {}),
        ),
      ],
    );
  }

  Widget _buildNotificationPreferences(bool isMobile) {
    return _buildTabContainer(
      title: 'Notifications',
      subtitle: 'How you want to be notified',
      children: [
        _buildNotificationRow('Applications', ['Email', 'Push', 'Whatsapp']),
        _buildNotificationRow('Interviews', ['Email', 'SMS', 'Push']),
        _buildNotificationRow('Messages', ['Email', 'Push']),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _buildPrimaryButton('Save Preferences', onPressed: () {}),
        ),
      ],
    );
  }

  Widget _buildNotificationRow(String title, List<String> types) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((type) => _buildMiniCheckbox(type)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCheckbox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Checkbox(
              value: label == 'Email' || label == 'Push',
              onChanged: (v) {},
              activeColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildPreferences(bool isMobile) {
    return _buildTabContainer(
      title: 'Preferences',
      subtitle: 'Customize your experience',
      children: [
        _buildCompactDropdown('Timezone', _selectedTimezone, _timezones, (v) => setState(() => _selectedTimezone = v!)),
        const SizedBox(height: 16),
        _buildCompactDropdown('Language', 'English (US)', ['English (US)', 'Hindi', 'Spanish'], (v) {}),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _buildPrimaryButton('Apply Preferences', onPressed: () {}),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings(bool isMobile) {
    return _buildTabContainer(
      title: 'Security',
      subtitle: 'Manage your access settings',
      children: [
        _buildCompactField('Current Password', '', isPass: true),
        const SizedBox(height: 16),
        _buildCompactField('New Password', '', isPass: true),
        const SizedBox(height: 16),
        _buildCompactField('Confirm Password', '', isPass: true),
        const SizedBox(height: 16),
        _buildPasswordTips(),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _buildPrimaryButton('Update Security', onPressed: () {}, color: const Color(0xFFEF4444)),
        ),
      ],
    );
  }

  Widget _buildPasswordTips() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.info, size: 14, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tips: Use 8+ chars with letters, numbers, and symbols.',
              style: TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildTabContainer({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16), // Even more compact padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCompactField(String label, String val, {String? helper, bool isPass = false, int lines = 1, bool isPlaceholder = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        SizedBox(
          height: lines > 1 ? null : 38,
          child: TextField(
            controller: TextEditingController(text: isPlaceholder ? null : val),
            obscureText: isPass,
            maxLines: lines,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: isPlaceholder ? val : null,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ],
    );
  }

  Widget _buildCompactDropdown(String label, String val, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 5),
        Container(
          height: 34, // Even smaller height
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: val,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 12),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
              items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(String text, {required VoidCallback onPressed, bool isTransparent = false}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: isTransparent ? Colors.transparent : const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isTransparent ? const Color(0xFF6366F1) : const Color(0xFF64748B))),
    );
  }

  Widget _buildPrimaryButton(String text, {required VoidCallback onPressed, Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
