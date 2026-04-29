import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';

class Sidebar extends ConsumerStatefulWidget {
  final bool isCollapsed;
  final bool showCloseButton;
  final VoidCallback? onToggle;

  const Sidebar({
    super.key,
    this.isCollapsed = false,
    this.showCloseButton = false,
    this.onToggle,
  });

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  bool _isBillingExpanded = false;

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final activeIndex = navState.activeIndex;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildUserTop(context),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionTitle('MAIN MENU'),
                _buildMenuItem(context, ref, 0, 'Dashboard', LucideIcons.layoutDashboard, isActive: activeIndex == 0),
                _buildMenuItem(context, ref, 1, 'Candidates', LucideIcons.users, isActive: activeIndex == 1),
                _buildMenuItem(context, ref, 2, 'Jobs', LucideIcons.briefcase, isActive: activeIndex == 2),
                _buildMenuItem(context, ref, 3, 'Interviews', LucideIcons.calendar, isActive: activeIndex == 3),
                const SizedBox(height: 24),
                _buildMenuItem(context, ref, 4, 'Analytics', LucideIcons.barChart3, isActive: activeIndex == 4),
                _buildMenuItem(context, ref, 5, 'Messaging', LucideIcons.messageSquare, isActive: activeIndex == 5),
                _buildExpandableMenuItem(
                  context,
                  ref,
                  6,
                  'Billing & Invoices',
                  LucideIcons.creditCard,
                  _isBillingExpanded,
                  () => setState(() => _isBillingExpanded = !_isBillingExpanded),
                  [
                    _buildSubMenuItem(context, ref, 6, 'Billing Overview', activeIndex == 6),
                    _buildSubMenuItem(context, ref, 61, 'Transactions', activeIndex == 61),
                    _buildSubMenuItem(context, ref, 62, 'Invoices', activeIndex == 62),
                    _buildSubMenuItem(context, ref, 8, 'My Subscription', activeIndex == 8),
                    _buildSubMenuItem(context, ref, 63, 'Payment Methods', activeIndex == 63),
                    _buildSubMenuItem(context, ref, 64, 'Billing Settings', activeIndex == 64),
                  ],
                  isActive: activeIndex == 6 || (activeIndex >= 61 && activeIndex <= 64) || activeIndex == 8,
                ),
                const SizedBox(height: 12),
                _buildSpecialMenuItem(context, ref, 8, 'Subscription Plans', LucideIcons.sparkles, isActive: activeIndex == 8),
                _buildMenuItem(context, ref, 7, 'Settings', LucideIcons.settings, isActive: activeIndex == 7),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 24, endIndent: 24),
          _buildLogoutButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.logOut,
                size: 20,
                color: AppColors.error,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTop(BuildContext context) {
    if (widget.isCollapsed) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFEDE9FE),
        child: const Text('AD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEDE9FE),
            child: const Text('AD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin User',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  'Super Admin',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          if (widget.showCloseButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF94A3B8)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    if (widget.isCollapsed) return const Divider();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    String title,
    IconData icon,
    bool isExpanded,
    VoidCallback onToggle,
    List<Widget> children, {
    bool isActive = false,
  }) {
    if (widget.isCollapsed) {
      return _buildMenuItem(context, ref, index, title, icon, isActive: isActive);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF5F3FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(BuildContext context, WidgetRef ref, int index, String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF5F3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialMenuItem(BuildContext context, WidgetRef ref, int index, String title, IconData icon, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF6366F1),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, int index, String title, IconData icon, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF5F3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1), // Indigo indicator
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
