import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/dashboard_date_provider.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class Header extends ConsumerWidget {
  final VoidCallback onMenuPressed;

  const Header({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Container(
      height: isDesktop ? 80 : 70,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(LucideIcons.menu, color: Color(0xFF64748B), size: 28),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildSearchBar(),
            ),
          ],
          const Spacer(),
          if (isDesktop) ...[
            _buildDateFilter(context, ref, false),
            const SizedBox(width: 12),
          ],
          _buildProfileDropdown(context, ref, isDesktop),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search candidates, jobs, or keywords...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(LucideIcons.search, color: Color(0xFF94A3B8), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context, WidgetRef ref, bool isMobile) {
    final selectedDate = ref.watch(dashboardDateProvider);
    final dateStr = isMobile 
        ? DateFormat('MMM dd').format(selectedDate)
        : DateFormat('MMM dd, yyyy').format(selectedDate);

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF6366F1),
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          ref.read(dashboardDateProvider.notifier).setDate(picked);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, WidgetRef ref, bool isDesktop) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        final nav = ref.read(navigationProvider.notifier);
        switch (value) {
          case 'profile':
            nav.setIndex(100);
            nav.setProfileStep(0);
            break;
          case 'company':
            nav.setIndex(102);
            break;
          case 'documents':
            nav.setIndex(101);
            break;
          case 'settings':
            nav.setIndex(7);
            break;
          case 'signout':
            Navigator.of(context).pushReplacementNamed('/login');
            break;
        }
      },
      child: Row(
        children: [
          if (isDesktop) ...[
            const Text(
              'Mindware info tech',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (context) => [
        _buildPopupItem('Your Profile', LucideIcons.user, 'profile'),
        _buildPopupItem('Company Profile', LucideIcons.building, 'company'),
        _buildPopupItem('Documents', LucideIcons.fileText, 'documents'),
        _buildPopupItem('Settings', LucideIcons.settings, 'settings'),
        const PopupMenuDivider(),
        _buildPopupItem('Sign out', LucideIcons.logOut, 'signout', isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String title, IconData icon, String value, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? AppColors.error : const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? AppColors.error : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
