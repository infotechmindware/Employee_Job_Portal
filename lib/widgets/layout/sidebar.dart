import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7C3AED), // Violet 600
            Color(0xFF6366F1), // Indigo 500
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildBrandHeader(context),
          const SizedBox(height: 24),
          if (!widget.isCollapsed) _buildCreateNewButton(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildMenuItem(context, ref, 0, 'Dashboard', LucideIcons.home, isActive: activeIndex == 0),
                _buildMenuItem(context, ref, 1, 'Jobs', LucideIcons.briefcase, isActive: activeIndex == 1),
                _buildMenuItem(context, ref, 2, 'Candidates', LucideIcons.users, isActive: activeIndex == 2),
                _buildMenuItem(context, ref, 3, 'Interviews', LucideIcons.calendar, isActive: activeIndex == 3),
                _buildMenuItem(context, ref, 5, 'Messages', LucideIcons.messageCircle, isActive: activeIndex == 5),
                _buildMenuItem(context, ref, 4, 'Analytics', LucideIcons.barChart3, isActive: activeIndex == 4),
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
                _buildMenuItem(context, ref, 8, 'Subscription Plans', LucideIcons.sparkles, isActive: activeIndex == 8),
                _buildMenuItem(context, ref, 7, 'Settings', LucideIcons.settings, isActive: activeIndex == 7),
              ],
            ),
          ),
          _buildLogoutButton(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.menu, size: 28, color: Color(0xFF6366F1)),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 16),
            const Text(
              'Mindware',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
          if (widget.showCloseButton) ...[
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(LucideIcons.x, size: 20, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateNewButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.plus, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 10),
              Text(
                'Create New',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, int index, String title, IconData icon, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? Colors.white : Colors.white.withOpacity(0.7)),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
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
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: isActive ? Colors.white : Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(BuildContext context, WidgetRef ref, int index, String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InkWell(
        onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () async {
          await ref.read(authProvider.notifier).logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(LucideIcons.logOut, size: 20, color: Colors.white70),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 14),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
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
