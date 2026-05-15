import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/theme_provider.dart';

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
    {'title': 'Security', 'icon': LucideIcons.shieldCheck},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            _buildTabNavigation(isDesktop, theme),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? screenWidth * 0.15 : 20,
                  vertical: 24,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedTabIndex),
                    child: _buildContentPanel(theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onBackground,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account and preferences.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(bool isDesktop, ThemeData theme) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _tabs[index]['icon'],
                      size: 18,
                      color: isSelected ? theme.cardColor : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _tabs[index]['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? theme.cardColor : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentPanel(ThemeData theme) {
    switch (_selectedTabIndex) {
      case 0: return _buildAccountTab(theme);
      case 1: return _buildCompanyTab(theme);
      case 2: return _buildNotificationsTab(theme);
      case 3: return _buildPreferencesTab(theme);
      case 4: return _buildSecurityTab(theme);
      default: return const SizedBox();
    }
  }

  Widget _buildAccountTab(ThemeData theme) {
    return Column(
      children: [
        _buildProfileHeader(theme),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme: theme,
          title: 'Primary Information',
          icon: LucideIcons.user,
          children: [
            _buildModernTextField(
              theme: theme,
              label: 'Email Address',
              controller: TextEditingController(text: 'sujit2@gmail.com'),
              icon: LucideIcons.mail,
              helper: 'Your primary contact and login email',
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              theme: theme,
              label: 'Phone Number',
              controller: TextEditingController(text: '+91 9334748028'),
              icon: LucideIcons.phone,
              helper: 'Used for two-factor authentication',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildVerificationCard(theme),
        const SizedBox(height: 24),
        _buildActionCard(
          theme: theme,
          title: 'Account Status',
          description: 'Your account is currently active and in good standing. Keep your details updated to receive critical platform alerts.',
          actionLabel: 'Save Changes',
          onAction: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.cardColor.withOpacity(0.2), width: 3),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text(
                'S',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sujit Kumar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 10, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Verified Employer',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(LucideIcons.camera, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(ThemeData theme) {
    return Column(
      children: [
        _buildCompanyHeader(theme),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme: theme,
          title: 'Organization Details',
          icon: LucideIcons.building,
          children: [
            _buildModernTextField(
              theme: theme,
              label: 'Company Name',
              controller: TextEditingController(text: 'Mindware Info Tech'),
              icon: LucideIcons.briefcase,
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              theme: theme,
              label: 'Corporate Website',
              controller: TextEditingController(text: 'https://mindwareinfotech.com'),
              icon: LucideIcons.globe,
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              theme: theme,
              label: 'Company Description',
              controller: TextEditingController(text: 'Innovation-driven software solutions provider focusing on enterprise excellence.'),
              icon: LucideIcons.fileText,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildModernDropdown(
                    theme: theme,
                    label: 'Industry',
                    value: _selectedIndustry,
                    items: _industries,
                    onChanged: (v) => setState(() => _selectedIndustry = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernDropdown(
                    theme: theme,
                    label: 'Size',
                    value: _selectedCompanySize,
                    items: _companySizes,
                    onChanged: (v) => setState(() => _selectedCompanySize = v!),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionCard(
          theme: theme,
          title: 'Update Corporate Identity',
          description: 'Ensure your company profile is up to date to attract high-quality candidates and maintain trust.',
          actionLabel: 'Update Profile',
          onAction: () {},
        ),
      ],
    );
  }

  Widget _buildCompanyHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.05) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(LucideIcons.briefcase, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mindware Info Tech',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -0.3),
                ),
                Text(
                  'Corporate Account • Premium',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildSmallActionBtn('Edit Logo', () {}),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(ThemeData theme) {
    return Column(
      children: [
        _buildSectionCard(
          theme: theme,
          title: 'Communication Channels',
          icon: LucideIcons.bell,
          children: [
            _buildNotificationSetting(
              theme: theme,
              title: 'Job Applications',
              subtitle: 'New candidate applications and status changes',
              channels: ['Email', 'Push', 'WhatsApp'],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: theme.dividerColor.withOpacity(0.1), thickness: 1.2),
            ),
            _buildNotificationSetting(
              theme: theme,
              title: 'Interview Management',
              subtitle: 'Schedule confirmations and reminders',
              channels: ['Email', 'SMS', 'Push'],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: theme.dividerColor.withOpacity(0.1), thickness: 1.2),
            ),
            _buildNotificationSetting(
              theme: theme,
              title: 'In-App Messaging',
              subtitle: 'Direct chat notifications from candidates',
              channels: ['Email', 'Push'],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildPremiumButton(
          label: 'Save Notification Preferences',
          icon: LucideIcons.checkCircle,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPreferencesTab(ThemeData theme) {
    return Column(
      children: [
        _buildSectionCard(
          theme: theme,
          title: 'Regional Settings',
          icon: LucideIcons.globe,
          children: [
            _buildModernDropdown(
              theme: theme,
              label: 'Timezone',
              value: _selectedTimezone,
              items: _timezones,
              onChanged: (v) => setState(() => _selectedTimezone = v!),
            ),
            const SizedBox(height: 16),
            _buildModernDropdown(
              theme: theme,
              label: 'System Language',
              value: 'English (US)',
              items: ['English (US)', 'Hindi', 'Spanish'],
              onChanged: (v) {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          theme: theme,
          title: 'Interface Style',
          icon: LucideIcons.palette,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Row(
                  children: [
                    _buildThemeChip(
                      'Light Mode', 
                      LucideIcons.sun, 
                      !themeProvider.isDarkMode,
                      () => themeProvider.toggleTheme(false),
                      theme,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeChip(
                      'Dark Mode', 
                      LucideIcons.moon, 
                      themeProvider.isDarkMode,
                      () => themeProvider.toggleTheme(true),
                      theme,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildPremiumButton(
          label: 'Apply System Preferences',
          icon: LucideIcons.check,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildThemeChip(String label, IconData icon, bool isActive, VoidCallback onTap, ThemeData theme) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.06) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primary : theme.dividerColor.withOpacity(0.1),
              width: isActive ? 1.8 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                size: 18, 
                color: isActive ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isActive ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTab(ThemeData theme) {
    return Column(
      children: [
        _buildSecurityStatusCard(theme),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme: theme,
          title: 'Authentication',
          icon: LucideIcons.lock,
          children: [
            _buildModernTextField(
              theme: theme,
              label: 'Current Password',
              controller: TextEditingController(),
              icon: LucideIcons.key,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              theme: theme,
              label: 'New Password',
              controller: TextEditingController(),
              icon: LucideIcons.shield,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _buildModernTextField(
              theme: theme,
              label: 'Confirm New Password',
              controller: TextEditingController(),
              icon: LucideIcons.shieldCheck,
              isPassword: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme: theme,
          title: 'Active Sessions',
          icon: LucideIcons.monitor,
          children: [
            _buildSessionItem('Samsung Galaxy M53', 'Delhi, India • Active Now', true, theme),
            Divider(color: theme.dividerColor.withOpacity(0.1), height: 32),
            _buildSessionItem('Windows Desktop', 'Kolkata, India • 2 hours ago', false, theme),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionCard(
          theme: theme,
          title: 'Account Protection',
          description: 'We recommend changing your password every 90 days to maintain security.',
          actionLabel: 'Update Password',
          onAction: () {},
          isDanger: true,
        ),
      ],
    );
  }

  Widget _buildSecurityStatusCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B).withOpacity(0.2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF065F46).withOpacity(0.3) : const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF065F46).withOpacity(0.4) : const Color(0xFFDCFCE7), 
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.shieldCheck, color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Secure',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w900, 
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF166534),
                  ),
                ),
                Text(
                  'Your security settings are up to date.',
                  style: TextStyle(
                    fontSize: 11, 
                    color: isDark ? const Color(0xFF34D399).withOpacity(0.7) : const Color(0xFF15803D), 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String device, String info, bool isActive, ThemeData theme) {
    return Row(
      children: [
        Icon(isActive ? LucideIcons.smartphone : LucideIcons.monitor, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
              Text(info, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF065F46).withOpacity(0.2) : const Color(0xFFDCFCE7), 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active', 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.w900, 
                color: theme.brightness == Brightness.dark ? const Color(0xFF34D399) : const Color(0xFF166534),
              ),
            ),
          )
        else
          _buildSmallActionBtn('Logout', () {}),
      ],
    );
  }

  // --- Premium Components ---

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children, required ThemeData theme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _buildVerificationCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF78350F).withOpacity(0.1) : const Color(0xFFFFF7ED).withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF92400E).withOpacity(0.3) : const Color(0xFFFFEDD5).withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.01),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF92400E).withOpacity(0.2) : const Color(0xFFFEF3C7), 
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.shieldAlert, color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Verification',
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 14, 
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                      ),
                    ),
                    Text(
                      'Phone number is not verified.',
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? const Color(0xFFFBBF24).withOpacity(0.7) : const Color(0xFFB45309), 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSmallActionBtn('Send OTP', () {}),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF92400E).withOpacity(0.3) : const Color(0xFFFED7AA)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: TextStyle(
                        fontSize: 13, 
                        color: isDark ? const Color(0xFFFBBF24).withOpacity(0.5) : const Color(0xFFD97706), 
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildModernButton('Verify', () {}, color: const Color(0xFFD97706)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    required ThemeData theme,
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 6),
          Text(
            description, 
            style: TextStyle(
              fontSize: 12, 
              color: theme.colorScheme.onSurface.withOpacity(0.6), 
              fontWeight: FontWeight.w500, 
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDanger ? const Color(0xFFEF4444) : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    String? helper,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            maxLines: maxLines,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              helper,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(LucideIcons.chevronDown, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              dropdownColor: theme.cardColor,
              items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSetting({
    required String title,
    required String subtitle,
    required List<String> channels,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: channels.map((channel) {
            final isEnabled = channel != 'WhatsApp' && channel != 'SMS';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.primary.withOpacity(0.06) : theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : theme.colorScheme.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEnabled ? AppColors.primary.withOpacity(0.15) : theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 18,
                    width: 28,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: isEnabled,
                        onChanged: (v) {},
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    channel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isEnabled ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernButton(String label, VoidCallback onTap, {Color? color}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
    );
  }

  Widget _buildPremiumButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionBtn(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF59E0B).withOpacity(0.1),
        foregroundColor: const Color(0xFFD97706),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}
