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

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Account', 'icon': LucideIcons.user},
    {'title': 'Company', 'icon': LucideIcons.building},
    {'title': 'Notifications', 'icon': LucideIcons.bell},
    {'title': 'Preferences', 'icon': LucideIcons.settings},
    {'title': 'Security', 'icon': LucideIcons.lock},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const Text(
              'Manage your account settings and preferences',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabSidebar(),
                  const SizedBox(width: 32),
                  Expanded(child: _buildContentPanel(isDesktop, isMobile)),
                ],
              )
            else
              Column(
                children: [
                  _buildMobileTabs(),
                  const SizedBox(height: 24),
                  _buildContentPanel(isDesktop, isMobile),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSidebar() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTabIndex == entry.key;
          return _buildTabItem(entry.value['title'], entry.value['icon'], isSelected, () {
            setState(() => _selectedTabIndex = entry.key);
          });
        }).toList(),
      ),
    );
  }

  Widget _buildMobileTabs() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEDE9FE) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(_tabs[index]['icon'], size: 16, color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text(
                    _tabs[index]['title'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(width: 2, height: 16, color: const Color(0xFF6366F1)),
            ],
          ],
        ),
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
      subtitle: 'Manage your account information',
      children: [
        _buildTextField('Email Address', 'sujeet1@gmail.com', helperText: 'We\'ll send important updates to this email'),
        const SizedBox(height: 24),
        _buildTextField('Phone Number', '+91 9334748028', helperText: 'Optional - for important notifications'),
        const SizedBox(height: 24),
        _buildTextField('Additional Mobile Number', 'Optional second number'),
        const SizedBox(height: 32),
        _buildVerificationBox(),
        const SizedBox(height: 32),
        _buildAccountStatus(),
        const SizedBox(height: 32),
        _buildSaveButton('Save Changes', isMobile),
      ],
    );
  }

  Widget _buildCompanyInformation(bool isMobile) {
    return _buildTabContainer(
      title: 'Company Information',
      subtitle: 'Update your company details',
      children: [
        _buildTextField('Company Name *', 'Mindware info tech sd'),
        const SizedBox(height: 24),
        _buildTextField('Website', 'https://chatgpt.com/c/69f1b735-5a1c-8321-aaad-7dc'),
        const SizedBox(height: 24),
        _buildTextField('Company Description', 'hello sanjay', maxLines: 4),
        const SizedBox(height: 24),
        _buildDropdown('Industry', 'Finance'),
        const SizedBox(height: 24),
        _buildDropdown('Company Size', '11-50 employees'),
        const SizedBox(height: 32),
        _buildSaveButton('Save Changes', isMobile),
      ],
    );
  }

  Widget _buildNotificationPreferences(bool isMobile) {
    final types = ['Job Application', 'Interview Schedule', 'New Message', 'Candidate Shortlisted', 'Marketing'];
    final channels = ['Email', 'SMS', 'Push', 'WhatsApp'];

    return _buildTabContainer(
      title: 'Notification Preferences',
      subtitle: 'Choose how and when you want to be notified',
      children: [
        ...types.map((type) => Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              isMobile 
                ? Column(children: channels.map((c) => _buildCheckboxRow(c)).toList())
                : Row(children: channels.map((c) => Expanded(child: _buildCheckboxRow(c))).toList()),
            ],
          ),
        )),
        _buildSaveButton('Save Preferences', isMobile),
      ],
    );
  }

  Widget _buildPreferences(bool isMobile) {
    return _buildTabContainer(
      title: 'Preferences',
      subtitle: 'Customize your experience',
      children: [
        _buildDropdown('Timezone', 'Asia/Kolkata (IST)'),
        const SizedBox(height: 8),
        const Text('This affects how dates and times are displayed', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 32),
        _buildSaveButton('Save Preferences', isMobile),
      ],
    );
  }

  Widget _buildSecuritySettings(bool isMobile) {
    return _buildTabContainer(
      title: 'Security',
      subtitle: 'Manage your password and security settings',
      children: [
        _buildTextField('Current Password', '', isPassword: true),
        const SizedBox(height: 24),
        _buildTextField('New Password', '', isPassword: true, helperText: 'Must be at least 8 characters long'),
        const SizedBox(height: 24),
        _buildTextField('Confirm New Password', '', isPassword: true),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Password Tips: Use a combination of letters, numbers, and special characters for better security.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSaveButton('Update Password', isMobile, isDestructive: true),
      ],
    );
  }

  Widget _buildTabContainer({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(value: true, onChanged: (v) {}, activeColor: const Color(0xFF6366F1), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildSaveButton(String text, bool isMobile, {bool isDestructive = false}) {
    return Align(
      alignment: isMobile ? Alignment.center : Alignment.centerRight,
      child: SizedBox(
        width: isMobile ? double.infinity : null,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildVerificationBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phone Verification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFB45309)),
              const SizedBox(width: 6),
              const Text('Phone not verified', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Send OTP', style: TextStyle(fontSize: 13, color: Color(0xFF6366F1)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: () {}, child: const Text('Verify OTP', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(LucideIcons.alertCircle, size: 14, color: Color(0xFFB45309)),
            const SizedBox(width: 6),
            const Text('Not Verified', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, {String? helperText, bool isPassword = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          obscureText: isPassword,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
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
              value: selected,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              items: [selected].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))))).toList(),
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }
}
