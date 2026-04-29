import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int _selectedBillingCycle = 0; // 0: Monthly, 1: Quarterly, 2: Annual
  int _selectedGateway = 0; // 0: Razorpay, 1: Cashfree
  String _selectedPlan = 'Premium';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 48 : 16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 48),
            _buildBillingAndGateway(isDesktop),
            const SizedBox(height: 40),
            _buildPromoCodeSection(isDesktop),
            const SizedBox(height: 48),
            _buildPlansSection(isDesktop),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Choose Your Plan',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the perfect plan for your hiring needs',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildBillingAndGateway(bool isDesktop) {
    return Container(
      width: isDesktop ? 600 : double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Text(
            'SELECT BILLING CYCLE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCycleButton(0, 'Monthly', null),
              const SizedBox(width: 8),
              _buildCycleButton(1, 'Quarterly', 'Save 10%'),
              const SizedBox(width: 8),
              _buildCycleButton(2, 'Annual', 'Save 20%'),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'SELECT PAYMENT GATEWAY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGatewayButton(0, 'Razorpay', LucideIcons.creditCard),
              const SizedBox(width: 16),
              _buildGatewayButton(1, 'Cashfree', LucideIcons.wallet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleButton(int index, String title, String? subtitle) {
    final isSelected = _selectedBillingCycle == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedBillingCycle = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGatewayButton(int index, String title, IconData icon) {
    final isSelected = _selectedGateway == index;
    return InkWell(
      onTap: () => setState(() => _selectedGateway = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(bool isDesktop) {
    return Container(
      width: isDesktop ? 600 : double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.helpCircle, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Have a discount code?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(bool isDesktop) {
    final plans = [
      {
        'title': 'Free',
        'desc': 'Perfect for startups and small businesses',
        'price': '0',
      },
      {
        'title': 'Basic',
        'desc': 'Essential features for growing businesses',
        'price': '400',
      },
      {
        'title': 'Premium',
        'desc': 'Advanced features for established companies',
        'price': '850',
        'isPopular': true,
      },
      {
        'title': 'Enterprise',
        'desc': 'Custom solutions for large organizations',
        'price': '1,650',
      },
    ];

    if (!isDesktop) {
      return Column(
        children: plans.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildPlanCard(p, true),
        )).toList(),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPlanCard(plans[0], false)),
            const SizedBox(width: 24),
            Expanded(child: _buildPlanCard(plans[1], false)),
            const SizedBox(width: 24),
            Expanded(child: _buildPlanCard(plans[2], false)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildPlanCard(plans[3], false)),
            const Spacer(flex: 2),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p, bool isMobile) {
    final isPopular = p['isPopular'] == true;
    final isSelected = _selectedPlan == p['title'];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isPopular ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: isSelected || isPopular ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(p['desc'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('₹${p['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text(' /monthly', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              const Center(
                child: Text('+GST as applicable', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedPlan = p['title']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
