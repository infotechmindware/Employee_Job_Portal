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
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: Icon(LucideIcons.menu, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 28),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildSearchBar(context),
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF1F5F9) : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search candidates, jobs, or keywords...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 13),
          prefixIcon: Icon(LucideIcons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
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
            final theme = Theme.of(context);
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: theme.colorScheme.onSurface,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
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
            Text(
              'Mindware info tech',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
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
        _buildPopupItem(context, 'Your Profile', LucideIcons.user, 'profile'),
        _buildPopupItem(context, 'Company Profile', LucideIcons.building, 'company'),
        _buildPopupItem(context, 'Documents', LucideIcons.fileText, 'documents'),
        _buildPopupItem(context, 'Settings', LucideIcons.settings, 'settings'),
        const PopupMenuDivider(),
        _buildPopupItem(context, 'Sign out', LucideIcons.logOut, 'signout', isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(BuildContext context, String title, IconData icon, String value, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
