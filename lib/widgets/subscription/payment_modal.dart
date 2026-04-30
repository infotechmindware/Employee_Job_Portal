import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PaymentModal extends StatefulWidget {
  final String planTitle;
  final String price;

  const PaymentModal({
    super.key,
    required this.planTitle,
    required this.price,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  int _selectedTab = 0; // 0: UPI, 1: Cards, 2: Netbanking, 3: Wallet

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
        child: Container(
          width: 850,
          height: isMobile ? null : 550,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF2563EB),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('MindInfotech', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price Summary', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('₹${widget.price}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.user, color: Colors.white70, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Using as +91 93347 49028',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
                const Spacer(),
                const Text('Secured by Razorpay', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        // Right Side
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    _buildTabs(),
                    const VerticalDivider(width: 1, color: Color(0xFFF1F5F9)),
                    Expanded(child: _buildTabContent()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF2563EB),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MindInfotech', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('₹${widget.price}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Quarterly Subscription', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMobileTab(0, 'UPI'),
                      _buildMobileTab(1, 'Cards'),
                      _buildMobileTab(2, 'Netbanking'),
                      _buildMobileTab(3, 'Wallet'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Payment Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          _buildTabItem(0, 'UPI', LucideIcons.smartphone),
          _buildTabItem(1, 'Cards', LucideIcons.creditCard),
          _buildTabItem(2, 'Netbanking', LucideIcons.landmark),
          _buildTabItem(3, 'Wallet', LucideIcons.wallet),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        color: isSelected ? const Color(0xFFF8FAFC) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(width: 3, height: 20, color: const Color(0xFF2563EB)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildUPIView();
      case 1:
        return _buildCardsView();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.construction, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Under Development', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
    }
  }

  Widget _buildUPIView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('UPI QR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Spacer(),
              Icon(LucideIcons.clock, size: 14, color: Color(0xFF94A3B8)),
              SizedBox(width: 4),
              Text('11:43', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Placeholder for QR Code
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(child: Icon(LucideIcons.qrCode, size: 100, color: Color(0xFF1E293B))),
                ),
                const SizedBox(height: 20),
                const Text('Scan the QR using any UPI App', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUPIIcon(const Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    _buildUPIIcon(const Color(0xFF10B981)),
                    const SizedBox(width: 12),
                    _buildUPIIcon(const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '9875505813@okbizaxis',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildUPIIcon(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(child: Icon(LucideIcons.smartphone, size: 14, color: color)),
    );
  }

  Widget _buildCardsView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add a new card', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 24),
          _buildCardField('Card Number', '0000 0000 0000 0000'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCardField('MM / YY', 'MM / YY')),
              const SizedBox(width: 16),
              Expanded(child: _buildCardField('CVV', '123')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Save this card as per RBI guidelines', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
