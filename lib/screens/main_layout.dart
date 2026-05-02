import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/candidates/candidates_screen.dart';
import '../screens/jobs/jobs_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/messaging/messaging_screen.dart';
import '../screens/interviews/interviews_screen.dart';
import '../screens/billing/billing_screen.dart';
import '../screens/billing/transactions_screen.dart';
import '../screens/billing/invoices_screen.dart';
import '../screens/billing/payment_methods_screen.dart';
import '../screens/billing/billing_settings_screen.dart';
import '../screens/subscription/subscription_plans_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_stepper_screen.dart';
import '../screens/profile/document_verification_screen.dart';
import '../screens/profile/company_profile_screen.dart';
import '../widgets/layout/sidebar.dart';
import '../widgets/layout/header.dart';
import '../theme/app_colors.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = [
    const DashboardScreen(),         // 0
    const JobsScreen(),              // 1 (Swapped to match Sidebar index 1)
    const CandidatesScreen(),        // 2 (Swapped to match Sidebar index 2)
    const InterviewsScreen(),        // 3
    const AnalyticsScreen(),         // 4
    const MessagingScreen(),         // 5
    const BillingScreen(),           // 6
    const SettingsScreen(),          // 7
    const SubscriptionPlansScreen(), // 8
    const TransactionsScreen(),      // 9 (61)
    const InvoicesScreen(),          // 10 (62)
    const PaymentMethodsScreen(),    // 11 (63)
    const BillingSettingsScreen(),   // 12 (64)
    const ProfileStepperScreen(),     // 13 (100)
    const DocumentVerificationScreen(), // 14 (101)
    const CompanyProfileScreen(),    // 15 (102)
  ];

  int _getStackIndex(int activeIndex) {
    switch (activeIndex) {
      case 0: return 0;
      case 1: return 1;
      case 2: return 2;
      case 3: return 3;
      case 4: return 4;
      case 5: return 5;
      case 6: return 6;
      case 7: return 7;
      case 8: return 8;
      case 61: return 9;
      case 62: return 10;
      case 63: return 11;
      case 64: return 12;
      case 100: return 13;
      case 101: return 14;
      case 102: return 15;
      default: return 0;
    }
  }

  int _getBottomNavIndex(int activeIndex) {
    if (activeIndex == 2) return 1; // Candidates
    if (activeIndex == 1) return 2; // Jobs
    if (activeIndex == 5) return 3; // Messages
    if (activeIndex == 4) return 4; // Analytics
    return 0; // Default Dashboard for others
  }

  void _onBottomNavTap(int index) {
    int targetIndex = 0;
    if (index == 1) targetIndex = 2; // Candidates
    else if (index == 2) targetIndex = 1; // Jobs
    else if (index == 3) targetIndex = 5; // Messages
    else if (index == 4) targetIndex = 4; // Analytics
    ref.read(navigationProvider.notifier).setIndex(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final activeIndex = navState.activeIndex;
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.3),
      drawer: !isDesktop 
        ? Drawer(
            backgroundColor: Colors.white,
            width: MediaQuery.of(context).size.width * 0.7,
            child: const Sidebar(showCloseButton: true),
          )
        : null,
      bottomNavigationBar: !isDesktop 
        ? BottomNavigationBar(
            currentIndex: _getBottomNavIndex(activeIndex),
            onTap: _onBottomNavTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''), // Candidates
              BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: ''), // Jobs
              BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: ''), // Messages
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: ''), // Analytics
            ],
          )
        : null,
      body: Row(
        children: [
          if (isDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSidebarCollapsed ? 80 : 280,
              child: Sidebar(
                isCollapsed: _isSidebarCollapsed,
                onToggle: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Builder(
                    builder: (context) => Header(
                      onMenuPressed: () {
                        if (!isDesktop) {
                          Scaffold.of(context).openDrawer();
                        } else {
                          setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: IndexedStack(
                      index: _getStackIndex(activeIndex),
                      children: _screens,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
