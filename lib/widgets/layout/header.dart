import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';

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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
            icon: const Icon(LucideIcons.menu, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 16),
          if (isDesktop) ...[
            Expanded(
              flex: 2,
              child: _buildSearchBar(),
            ),
            const Spacer(),
            _buildDateFilter(),
            const SizedBox(width: 24),
          ],
          if (!isDesktop) const Spacer(),
          _buildProfileDropdown(context, ref),
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

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
          SizedBox(width: 8),
          Text(
            'Apr 30, 2026',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, WidgetRef ref) {
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
          const Text(
            'Mindware info tech',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(width: 12),
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
