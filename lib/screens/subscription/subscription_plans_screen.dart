import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../theme/app_colors.dart';
import 'subscription_dashboard_screen.dart';
import '../../services/subscription_service.dart';
import '../../services/auth_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int _selectedBillingCycle = 0; // 0: Monthly, 1: Quarterly, 2: Annual
  int _selectedGateway = 0; // 0: Razorpay, 1: Cashfree
  String _selectedPlan = 'Premium';
  final FocusNode _promoFocusNode = FocusNode();
  bool _isPromoFocused = false;
  bool _isProcessing = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _promoFocusNode.addListener(() {
      setState(() {
        _isPromoFocused = _promoFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    _promoFocusNode.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("✅ [Razorpay] Payment Success: ${response.paymentId}");
    _verifyPaymentOnBackend(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("🚨 [Razorpay] Payment Error: ${response.code} - ${response.message}");
    setState(() => _isProcessing = false);
    _showSnackBar("Payment Failed: ${response.message}", Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("💼 [Razorpay] External Wallet: ${response.walletName}");
    setState(() => _isProcessing = false);
  }

  void _verifyPaymentOnBackend(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    debugPrint("🔍 [Razorpay] Verifying payment on server: ${response.paymentId}");
    
    try {
      final verifyRes = await SubscriptionService.verifyPayment(
        orderId: response.orderId ?? "",
        paymentId: response.paymentId ?? "",
        signature: response.signature ?? "",
      );

      if (verifyRes['success']) {
        debugPrint("✅ [Razorpay] Server Verification Successful");
        _showSuccessUI(response.paymentId ?? "");
      } else {
        debugPrint("❌ [Razorpay] Server Verification Failed: ${verifyRes['message']}");
        _showSnackBar(verifyRes['message'] ?? "Payment verification failed", Colors.red);
      }
    } catch (e) {
      debugPrint("❌ [Razorpay] Verification Error: $e");
      _showSnackBar("Verification Error: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _startPaymentFlow(String planTitle, String price) async {
    setState(() => _isProcessing = true);
    debugPrint("🚀 [Razorpay] Initiating Mobile Payment Flow for: $planTitle");

    try {
      // Map plan title to ID as expected by backend
      int planId = 1; // Default to Basic
      if (planTitle == 'Premium') planId = 2;
      if (planTitle == 'Enterprise') planId = 3;

      final orderResponse = await SubscriptionService.createOrder(
        planId: planId,
        gateway: 'razorpay',
      );

      if (!orderResponse['success']) {
        throw Exception(orderResponse['message'] ?? "Failed to create order");
      }

      final data = orderResponse['data'];
      
      // IMPORTANT: Amount already comes in paise from backend. Do NOT multiply.
      final dynamic amount = data['amount'];
      final String? orderId = data['order_id'];
      final String? razorpayKey = data['razorpay_key'];

      debugPrint("🔑 [Razorpay] Order ID: $orderId");
      debugPrint("💰 [Razorpay] Amount (Paise): $amount");

      if (orderId == null || orderId.isEmpty) {
        throw Exception("Backend did not provide a valid order_id");
      }

      // Fetch user info for prefill if possible
      // Using existing defaults if not available
      final String userEmail = 'employer@mindware.com';
      final String userPhone = '+919334749028';

      var options = {
        'key': razorpayKey,
        'amount': amount,
        'order_id': orderId,
        'name': 'Mindware',
        'description': '$planTitle Subscription Payment',
        'currency': 'INR',
        'timeout': 300,
        'prefill': {
          'contact': userPhone,
          'email': userEmail
        },
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
      };

      debugPrint("💳 [Razorpay] Opening SDK with Options: $options");
      _razorpay.open(options);
    } catch (e) {
      debugPrint("🚨 [Razorpay] Mobile Error: $e");
      _showSnackBar("Payment Error: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessUI(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.checkCircle, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              const Text('Payment Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Your subscription is now active.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Ref: $paymentId', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Pop success dialog
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SubscriptionDashboardScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SELECT BILLING CYCLE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildCycleButton(0, 'Monthly', ''),
                const SizedBox(width: 12),
                _buildCycleButton(1, 'Quarterly', 'Save 10%'),
                const SizedBox(width: 12),
                _buildCycleButton(2, 'Annual', 'Save 20%'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SELECT PAYMENT GATEWAY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildGatewayButton(0, 'Razorpay', 'assets/images/razar.png')),
              const SizedBox(width: 12),
              Expanded(child: _buildGatewayButton(1, 'Cashfree', 'assets/images/cashfree.ico')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleButton(int index, String title, String subtitle) {
    final isSelected = _selectedBillingCycle == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedBillingCycle = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGatewayButton(int index, String title, String assetPath) {
    final isSelected = _selectedGateway == index;
    return InkWell(
      onTap: () => setState(() => _selectedGateway = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 18, height: 18, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isPromoFocused ? const Color(0xFF6366F1) : const Color(0xFFD1D5DB),
                      width: 1.2,
                    ),
                    boxShadow: _isPromoFocused
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.15),
                              blurRadius: 0,
                              spreadRadius: 3,
                            )
                          ]
                        : [],
                  ),
                  child: TextField(
                    focusNode: _promoFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
      },
      {
        'title': 'Basic',
        'desc': 'Essential features for growing businesses',
      },
      {
        'title': 'Premium',
        'desc': 'Advanced features for established companies',
        'isPopular': true,
      },
      {
        'title': 'Enterprise',
        'desc': 'Custom solutions for large organizations',
      },
    ];

    return Center(
      child: Wrap(
        spacing: 24,
        runSpacing: 32,
        alignment: WrapAlignment.center,
        children: plans.map((p) => _buildPlanCard(p, !isDesktop)).toList(),
      ),
    );
  }

  String _getPrice(String title) {
    if (title == 'Free') return '0';
    
    switch (_selectedBillingCycle) {
      case 0: // Monthly
        if (title == 'Basic') return '400';
        if (title == 'Premium') return '850';
        if (title == 'Enterprise') return '1,650';
        break;
      case 1: // Quarterly
        if (title == 'Basic') return '1,100';
        if (title == 'Premium') return '2,300';
        if (title == 'Enterprise') return '4,500';
        break;
      case 2: // Annual
        if (title == 'Basic') return '4,000';
        if (title == 'Premium') return '8,500';
        if (title == 'Enterprise') return '16,500';
        break;
    }
    return '0';
  }

  String _getCycleText() {
    switch (_selectedBillingCycle) {
      case 0: return ' /monthly';
      case 1: return ' /quarterly';
      case 2: return ' /annual';
      default: return ' /monthly';
    }
  }

  Widget _buildPlanCard(Map<String, dynamic> p, bool isMobile) {
    final isPopular = p['isPopular'] == true;
    final isSelected = _selectedPlan == p['title'];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isMobile ? double.infinity : 260,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected || isPopular ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: isSelected || isPopular ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
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
                  Text('₹${_getPrice(p['title'] as String)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Text(_getCycleText(), style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
              const Center(
                child: Text('+GST as applicable', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedPlan = p['title']);
                    
                    if (p['title'] == 'Free') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionDashboardScreen(),
                        ),
                      );
                    } else {
                      _startPaymentFlow(p['title'] as String, _getPrice(p['title'] as String));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isProcessing && _selectedPlan == p['title']
                      ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                      : const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
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
