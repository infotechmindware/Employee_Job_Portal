import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class _PaymentModalState extends State<PaymentModal> with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Shield Loader, 1: Main UI
  int _selectedTab = 0; // 0: UPI, 1: Cards, 2: Netbanking, 3: Wallet
  bool _saveCard = true;
  
  late ScrollController _cardScrollController;
  Timer? _cardTimer;
  
  late AnimationController _shieldController;
  late Animation<double> _shieldAnimation;
  
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late Timer _countdownTimer;
  int _secondsRemaining = 296; // 4:56
  
  @override
  void initState() {
    super.initState();
    
    _cardScrollController = ScrollController();
    _startCardSlider();
    
    // Shield Pulse Animation
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _shieldAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });

    // Auto transition from loader to main UI
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _animationController.dispose();
    _countdownTimer.cancel();
    _cardScrollController.dispose();
    _cardTimer?.cancel();
    super.dispose();
  }

  void _startCardSlider() {
    _cardTimer?.cancel();
    _cardTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_cardScrollController.hasClients) {
        final maxScroll = _cardScrollController.position.maxScrollExtent;
        final currentScroll = _cardScrollController.position.pixels;
        
        if (currentScroll >= maxScroll - 10) {
          _cardScrollController.animateTo(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        } else {
          _cardScrollController.animateTo(currentScroll + 296, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
      }
    });
  }

  void _stopCardSlider() {
    _cardTimer?.cancel();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _currentStep == 0 
            ? _buildShieldLoader() 
            : _buildMainPaymentUI(isDesktop),
        ),
      ),
    );
  }

  // --- STEP 1: SHIELD LOADER ---
  Widget _buildShieldLoader() {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 400,
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _shieldAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldCheck, size: 80, color: Color(0xFF2563EB)),
              ),
            ),
            const Spacer(),
            const Text('Secured by', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Razorpay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(width: 4),
                Icon(LucideIcons.shieldCheck, size: 14, color: Colors.blue.shade600),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: MAIN PAYMENT UI ---
  Widget _buildMainPaymentUI(bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isDesktop ? 24 : 12),
      elevation: 0,
      child: Container(
        width: isDesktop ? 850 : screenWidth * 0.95,
        height: isDesktop ? 600 : screenHeight * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Left Side: Blue Panel
              if (isDesktop) _buildLeftPanel(),
              
              // Right Side: Payment Options
              Expanded(
                child: _buildRightPanel(isDesktop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 280, // Reduced from 320
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B4EFF), Color(0xFF1E2FA0)],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Row(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3 * _animationController.value),
                          blurRadius: 15,
                          spreadRadius: (2 * _animationController.value).toDouble(),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/mindware.jpg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(LucideIcons.shieldCheck, color: Color(0xFF2B4EFF), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text('MindInfotech', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 48),
          
          // Price Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Summary', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Text('₹${widget.price}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // User Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.user, color: Color(0xFF2B4EFF), size: 16),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Using as +91 93347 49028',
                    style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: Color(0xFF2B4EFF), size: 16),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Illustration
          Center(
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Icon(LucideIcons.shoppingBag, size: 140, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('Fintech Illustration', style: TextStyle(color: Colors.white.withOpacity(0.05), fontSize: 10)),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Secured by', style: TextStyle(color: Colors.white70, fontSize: 10)),
              const SizedBox(width: 8),
              Image.asset('assets/images/razar.png', height: 12, color: Colors.white, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
              const SizedBox(width: 6),
              const Text('•', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(width: 6),
              const Text('Account & Terms', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDesktop) {
    return Column(
      children: [
        // Premium Header with Blue Background
        Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2B4EFF), Color(0xFF1E2FA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/mindware.jpg', width: 32, height: 32, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'MindInfotech',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  // Small version of the illustration in header
                  Opacity(
                    opacity: 0.8,
                    child: Image.asset('assets/images/google.png', width: 40, height: 40, color: Colors.white.withOpacity(0.2)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Branded Method Cards (Vertical List)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMethodCard(
                  0,
                  'UPI',
                  [
                    const Color(0xFF1D4ED8),
                    const Color(0xFF6D28D9),
                    const Color(0xFF0EA5E9),
                  ],
                  ['G', 'P', 'Pay'],
                  logoAssets: [
                    'assets/images/google.png',
                    'assets/images/Phone pe Customer Care toll-free number 8343099875.jpg',
                    'assets/images/paytm-logo-png_seeklogo-501241.png',
                  ],
                ),
                const SizedBox(height: 12),
                _buildMethodCard(
                  1,
                  'Cards',
                  [
                    const Color(0xFF1E293B),
                    const Color(0xFFDC2626),
                    const Color(0xFF1D4ED8),
                  ],
                  ['V', 'M', 'R'],
                  logoAssets: [
                    'assets/images/visa.svg',
                    'assets/images/amex.svg',
                    'assets/images/rupay.svg',
                  ],
                ),
                const SizedBox(height: 12),
                _buildMethodCard(
                  2,
                  'Netbanking',
                  [
                    const Color(0xFF1D4ED8),
                    const Color(0xFFEA580C),
                    const Color(0xFFDC2626),
                  ],
                  ['H', 'I', 'S'],
                  logoAssets: [
                    'assets/images/KKBK.gif',
                    'assets/images/BARB_R.gif',
                    'assets/images/CNRB.gif',
                    'assets/images/PUNB_R.gif',
                  ],
                ),
                const SizedBox(height: 12),
                _buildMethodCard(
                  3,
                  'Wallet',
                  [
                    const Color(0xFF16A34A),
                    const Color(0xFF2563EB),
                    const Color(0xFFFF9900),
                  ],
                  ['B', 'O', 'A'],
                  logoAssets: [
                    'assets/images/bajajpay.png',
                    'assets/images/olamoney.png',
                    'assets/images/amazonpay.png',
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Payment Options',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ),

                // Active Detail Section
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_selectedTab),
                    constraints: const BoxConstraints(minHeight: 300),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky Bottom Bar
        if (_selectedTab != 0)
          Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${widget.price}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  InkWell(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Text('View Details', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        Icon(LucideIcons.chevronUp, size: 12, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Secured by', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            const SizedBox(width: 8),
            Image.asset('assets/images/razar.png', height: 12, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
            const SizedBox(width: 8),
            Image.asset('assets/images/cashfree.ico', height: 12, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
            const SizedBox(width: 6),
            const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
            const SizedBox(width: 6),
            const Text('Account & Terms', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMethodCard(int index, String title, List<Color> logoColors, List<String> initials, {List<String>? logoAssets}) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2B4EFF).withOpacity(0.2) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            Row(
              children: List.generate(logoColors.length, (i) {
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: logoAssets != null && i < logoAssets.length ? Colors.transparent : logoColors[i].withOpacity(0.1),
                    child: logoAssets != null && i < logoAssets.length
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: logoAssets[i].endsWith('.svg')
                                ? SvgPicture.asset(
                                    logoAssets[i],
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (context) => Text(
                                      initials[i],
                                      style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: logoColors[i]),
                                    ),
                                  )
                                : Image.asset(
                                    logoAssets[i],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Text(
                                      initials[i],
                                      style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: logoColors[i]),
                                    ),
                                  ),
                          )
                        : Text(
                            initials[i],
                            style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: logoColors[i]),
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildUPIView();
      case 1: return _buildCardsView();
      case 2: return _buildNetBankingView();
      case 3: return _buildWalletView();
      default: 
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertTriangle, color: Color(0xFF94A3B8), size: 48),
              SizedBox(height: 16),
              Text('No payment options available', style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        );
    }
  }

  Widget _buildUPIView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('UPI QR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(LucideIcons.clock, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(_formatTime(_secondsRemaining),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B4EFF))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Code
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Image.asset('assets/images/payment_qr.png', width: 160, height: 160),
              ),
              const SizedBox(width: 16),
              // Info & Logos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Scan the QR using any UPI App',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSmallLogo('assets/images/Phone pe Customer Care toll-free number 8343099875.jpg'),
                        _buildSmallLogo('assets/images/google.png'),
                        _buildSmallLogo('assets/images/paytm-logo-png_seeklogo-501241.png'),
                        _buildSmallLogo('assets/images/amazonpay.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallLogo(String asset) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildCardsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saved Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          
          // Auto-sliding Saved Cards Carousel
          MouseRegion(
            onEnter: (_) => _stopCardSlider(),
            onExit: (_) => _startCardSlider(),
            child: Listener(
              onPointerDown: (_) => _stopCardSlider(),
              onPointerUp: (_) => _startCardSlider(),
              onPointerCancel: (_) => _startCardSlider(),
              child: SizedBox(
                height: 100, // Safe height to prevent overflow
                child: ListView.builder(
                  controller: _cardScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: 4, // Mock 4 saved cards
                  itemBuilder: (context, index) {
                    final isSelected = index == 0;
                    final cards = [
                      {'name': 'HDFC Bank Credit Card', 'num': '**** **** **** 4242', 'logo': 'assets/images/visa.svg'},
                      {'name': 'SBI Debit Card', 'num': '**** **** **** 1024', 'logo': 'assets/images/rupay.svg'},
                      {'name': 'ICICI Amazon Pay', 'num': '**** **** **** 8854', 'logo': 'assets/images/visa.svg'},
                      {'name': 'Axis Bank Credit', 'num': '**** **** **** 3391', 'logo': 'assets/images/amex.svg'},
                    ];
                    final card = cards[index];

                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? const Color(0xFF13489C) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: SvgPicture.asset(
                              card['logo']!,
                              width: 32,
                              height: 20,
                              fit: BoxFit.contain,
                              placeholderBuilder: (_) => Text(card['logo']!.contains('visa') ? 'VISA' : 'CARD', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(card['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(card['num']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(LucideIcons.checkCircle2, color: Color(0xFF13489C), size: 22),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('Add a new card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          
          // New Card Form Wrapper
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Card Number', '0000 0000 0000 0000'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Expiry', 'MM / YY')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('CVV', '123')),
                  ],
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    setState(() {
                      _saveCard = !_saveCard;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _saveCard ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(color: _saveCard ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _saveCard 
                              ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Save this card as per RBI guidelines', 
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildNetBankingView() {
    final suggestedBanks = [
      {
        'name': 'Kotak Mahindra Bank',
        'logo': 'assets/images/KKBK.gif',
        'subtitle': null,
      },
      {
        'name': 'Airtel Payments Bank',
        'logo': 'assets/images/AIRP.gif',
        'subtitle': null,
      },
      {
        'name': 'Bank of Baroda - Retail Banking',
        'logo': 'assets/images/BARB_R.gif',
        'subtitle': 'For Individuals',
      },
      {
        'name': 'Punjab National Bank - Retail Banking',
        'logo': 'assets/images/PUNB_R.gif',
        'subtitle': 'For Individuals',
      },
      {
        'name': 'Bank of India',
        'logo': 'assets/images/BKID.gif',
        'subtitle': null,
      },
      {
        'name': 'Canara Bank',
        'logo': 'assets/images/CNRB.gif',
        'subtitle': null,
      },
      {
        'name': 'Allahabad Bank',
        'logo': 'assets/images/ALLA.gif',
        'subtitle': null,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for Banks',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Suggested Banks',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestedBanks.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final bank = suggestedBanks[index];
                final isFirst = index == 0;
                return InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isFirst ? const Color(0xFFF1F5F9).withOpacity(0.5) : Colors.transparent,
                      borderRadius: isFirst 
                        ? const BorderRadius.vertical(top: Radius.circular(12))
                        : (index == suggestedBanks.length - 1 
                            ? const BorderRadius.vertical(bottom: Radius.circular(12))
                            : null),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Image.asset(bank['logo'] as String, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank['name'] as String,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              if (bank['subtitle'] != null)
                                Text(
                                  bank['subtitle'] as String,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF1E293B)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // All Banks Section
          InkWell(
            onTap: () => _showAllBanksModal(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('All Banks', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(width: 8),
                  Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF1E293B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllBanksModal() {
    final allBanks = [
      'HDFC Bank', 'ICICI Bank', 'State Bank of India', 'Axis Bank', 'HDFC Bank',
      'ICICI Bank', 'State Bank of India', 'Axis Bank', 'IndusInd Bank', 'Yes Bank',
      'Union Bank of India', 'Canara Bank', 'Punjab National Bank', 'Bank of Baroda',
      'IDFC First Bank', 'Federal Bank', 'South Indian Bank', 'Karnataka Bank',
      'RBL Bank', 'Standard Chartered', 'HSBC Bank', 'Citibank', 'Deutsche Bank',
      'DBS Bank', 'Saraswat Bank', 'SVC Bank', 'Cosmos Bank', 'TJSB Bank',
      'NKGSB Bank', 'Abhyudaya Bank'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Banks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: allBanks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(allBanks[index][0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    title: Text(allBanks[index], style: const TextStyle(fontSize: 14)),
                    onTap: () => Navigator.pop(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletView() {
    final wallets = [
      {'name': 'Amazon Pay', 'icon': LucideIcons.wallet},
      {'name': 'Ola Money', 'icon': LucideIcons.wallet},
      {'name': 'Bajaj Pay', 'icon': LucideIcons.wallet},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Wallet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          ListView.separated(
            itemCount: wallets.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: Icon(wallets[index]['icon'] as IconData, size: 18, color: const Color(0xFF64748B)),
                ),
                title: Text(wallets[index]['name'] as String, style: const TextStyle(fontSize: 14)),
                trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFFCBD5E1)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RazorpayLoadingScreen(price: widget.price)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF13489C), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Razorpay Mock Flow Widgets
// -----------------------------------------------------------------------------

class RazorpayLoadingScreen extends StatefulWidget {
  final String price;
  const RazorpayLoadingScreen({super.key, required this.price});

  @override
  State<RazorpayLoadingScreen> createState() => _RazorpayLoadingScreenState();
}

class _RazorpayLoadingScreenState extends State<RazorpayLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => RazorpayBankScreen(amount: widget.price)),
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => const CancelPaymentPopup(),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(child: Container(color: const Color(0xFF3366CC))), // Razorpay blue
                Expanded(child: Container(color: const Color(0xFFF4F6F8))), // Razorpay light grey
              ],
            ),
            Center(
              child: Container(
                width: 360,
                height: 280,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
                                child: Image.asset('assets/images/logo.png', height: 24, errorBuilder: (_,__,___) => const Icon(Icons.business, color: Color(0xFF1E293B))),
                              ),
                              const SizedBox(width: 12),
                              const Text('MindInfotech', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('PAYING', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                              Text('₹${widget.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(color: Color(0xFF3366CC), strokeWidth: 3),
                          ),
                          const SizedBox(height: 24),
                          const Text('Loading wallet page...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          const Text('Please wait while we redirect you to your wallet page.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Secured by', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          const SizedBox(width: 6),
                          Image.asset('assets/images/razar.png', height: 16, errorBuilder: (_,__,___) => const Text('Razorpay', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3366CC), fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RazorpayBankScreen extends StatelessWidget {
  final String amount;
  
  const RazorpayBankScreen({super.key, required this.amount});

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => const CancelPaymentPopup(),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Row(
            children: [
              Image.asset('assets/images/razar.png', height: 20, errorBuilder: (_,__,___) => const Icon(Icons.account_balance, color: Color(0xFF3366CC))),
              const SizedBox(width: 8),
              const Text('Razorpay Bank', style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => _onWillPop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('1', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF3366CC))),
              const SizedBox(height: 24),
              const Text('Welcome to Razorpay Software Private Ltd Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              const Text('This is just a demo bank page.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              const Text('You can choose whether to make this payment successful or not:', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful ✅', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF22C55E)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Success', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Failed ❌', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFFEF4444)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Failure', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CancelPaymentPopup extends StatelessWidget {
  const CancelPaymentPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.logOut, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Cancel Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            const Text('Your payment is ongoing. Are you sure you want to cancel the payment?', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('No, wait', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Cancelled', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF64748B)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
