import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'invoices_screen.dart';

class SubscriptionDashboardScreen extends StatelessWidget {
  const SubscriptionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Cleaner background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Accent Bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFEC7E2B), Color(0xFF7AB33D)]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isDesktop ? 48 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildMainDashboardLayout(context, isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboardLayout(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildMainContent(context)),
          const SizedBox(width: 32),
          Expanded(child: _buildSideContent(context)),
        ],
      );
    }
    return Column(
      children: [
        _buildMainContent(context),
        const SizedBox(height: 32),
        _buildSideContent(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Billing & Subscription',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 32, 
                  fontWeight: FontWeight.w900, 
                  color: const Color(0xFF1E1B4B), 
                  letterSpacing: -0.5
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Overview of your current plan and usage metrics',
                style: TextStyle(fontSize: isMobile ? 12 : 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildGradientButton(
          onPressed: () => Navigator.pop(context),
          icon: LucideIcons.arrowUpCircle,
          label: isMobile ? 'Upgrade' : 'Upgrade Plan',
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required IconData icon, required String label, bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFEC7E2B), Color(0xFF7AB33D)]),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 12),
        boxShadow: [BoxShadow(color: const Color(0xFFEC7E2B).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isMobile ? 14 : 18),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 12 : 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24, vertical: isMobile ? 8 : 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 20 : 12)),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        _buildCurrentPlanCard(),
        const SizedBox(height: 32),
        _buildUsageSection(),
      ],
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT PLAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF13489C), letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    const Text(
                      'Professional SaaS Plan',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildActiveBadge(),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildModernInfoRow('Billing Cycle', 'Quarterly', LucideIcons.calendarRange),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Color(0xFFE2E8F0))),
                _buildModernInfoRow('Next Invoice', '₹2,300 • Oct 24, 2026', LucideIcons.creditCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(30)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF16A34A)),
          SizedBox(width: 8),
          Text('ACTIVE', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Icon(icon, size: 16, color: const Color(0xFF13489C)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RESOURCE UTILIZATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF13489C), letterSpacing: 1.2)),
          const SizedBox(height: 32),
          _buildEnhancedUsageItem('Job Listings', '8', '15', 8 / 15, LucideIcons.briefcase),
          const SizedBox(height: 24),
          _buildEnhancedUsageItem('Candidate Contacts', '452', '1000', 452 / 1000, LucideIcons.users),
          const SizedBox(height: 24),
          _buildEnhancedUsageItem('Admin Seats', '3', '5', 3 / 5, LucideIcons.shieldCheck),
        ],
      ),
    );
  }

  Widget _buildEnhancedUsageItem(String label, String used, String total, double progress, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 14))),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: used, style: const TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.w900, fontSize: 16)),
                  TextSpan(text: ' / $total', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEC7E2B), Color(0xFF7AB33D)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSideContent(BuildContext context) {
    return Column(
      children: [
        _buildPremiumFeatureCard(),
        const SizedBox(height: 24),
        _buildModernHistoryCard(context),
      ],
    );
  }

  Widget _buildPremiumFeatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B), // Dark Navy
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PLAN FEATURES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFEC7E2B), letterSpacing: 1.5)),
          const SizedBox(height: 20),
          ...['Unlimited Listings', 'AI Talent Match', 'Priority Support', 'Custom Branding'].map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles, size: 14, color: Color(0xFF7AB33D)),
                const SizedBox(width: 12),
                Text(f, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildModernHistoryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BILLING HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF13489C), letterSpacing: 1.2)),
          const SizedBox(height: 24),
          _buildHistoryItem('May 2026', '₹850', 'Paid'),
          _buildHistoryItem('Apr 2026', '₹2,300', 'Paid'),
          const SizedBox(height: 16),
          _buildViewAllButton(context),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String date, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 13)),
              Text(amount, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF13489C))),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoicesScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)),
        child: const Center(
          child: Text('View Full History', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 13)),
        ),
      ),
    );
  }
}
