import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/subscription_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _billingData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBillingData();
  }

  Future<void> _fetchBillingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SubscriptionService.getBillingOverview();
      if (mounted) {
        if (response['success']) {
          setState(() {
            _billingData = response['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An unexpected error occurred: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _fetchBillingData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 24 : 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isDesktop),
                        const SizedBox(height: 32),
                        _buildTopStats(isDesktop),
                        const SizedBox(height: 32),
                        _buildMainContent(isDesktop),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_errorMessage ?? "Something went wrong", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchBillingData,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage your subscriptions, usage, and payments',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTopStats(bool isDesktop) {
    final overview = _billingData?['overview'] ?? {};
    final subscription = _billingData?['subscription'] ?? {};
    
    final stats = [
      {
        'title': 'Current Plan',
        'value': subscription['plan_name'] ?? overview['current_plan'] ?? 'Free',
        'subtitle': 'Renewal: ${subscription['next_billing_date'] ?? '—'}',
        'icon': LucideIcons.layers,
        'color': const Color(0xFF6366F1),
        'hasAction': true,
        'actionLabel': 'Manage plan',
      },
      {
        'title': 'Balance Due',
        'value': '₹${overview['balance_due'] ?? '0.00'}',
        'subtitle': overview['balance_due_text'] ?? 'No pending payments',
        'icon': LucideIcons.wallet,
        'color': const Color(0xFF10B981),
        'hasAction': true,
        'actionLabel': 'View invoices',
      },
      {
        'title': 'Upcoming Payment',
        'value': '₹${overview['upcoming_payment_amount'] ?? '—'}',
        'subtitle': 'On: ${overview['upcoming_payment_date'] ?? '—'}',
        'icon': LucideIcons.calendar,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Last Payment',
        'value': '₹${overview['last_payment_amount'] ?? '—'}',
        'subtitle': overview['last_payment_date'] ?? '—',
        'icon': LucideIcons.checkCircle,
        'color': const Color(0xFF2563EB),
        'hasAction': true,
        'actionLabel': 'View details',
      },
    ];

    if (!isDesktop) {
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: stats.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildInfoCard(stats[index], 260),
          ),
        ),
      );
    }

    return Row(
      children: stats.map((stat) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildInfoCard(stat, null),
        ),
      )).toList(),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> stat, double? width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat['title'] as String,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              Icon(stat['icon'] as IconData, size: 16, color: stat['color'] as Color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'] as String,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text(
            stat['subtitle'] as String,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          if (stat['hasAction'] == true) ...[
            const Spacer(),
            InkWell(
              onTap: () {},
              child: Text(
                stat['actionLabel'] as String,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: stat['color'] as Color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          _buildRecentTransactions(),
          const SizedBox(height: 24),
          _buildAlerts(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildRecentTransactions()),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildAlerts()),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = (_billingData?['recent_transactions'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          const Row(
            children: [
              Icon(LucideIcons.receipt, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(LucideIcons.history, size: 48, color: const Color(0xFFCBD5E1).withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      "No payment history found",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Get started by choosing a premium plan for your business.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 24),
                    _buildUpgradeButton(),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 32, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionItem(tx);
              },
            ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('View all invoices', LucideIcons.fileText),
              _buildActionButton('View all transactions', LucideIcons.list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Upgrade Now',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final String status = (tx['status'] ?? 'pending').toString().toLowerCase();
    Color statusColor = const Color(0xFF64748B);
    Color statusBg = const Color(0xFFF1F5F9);

    if (status == 'success' || status == 'completed') {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
    } else if (status == 'failed') {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
    } else if (status == 'processing') {
      statusColor = const Color(0xFF6366F1);
      statusBg = const Color(0xFFEEF2FF);
    } else if (status == 'pending') {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFFFBEB);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx['date'] ?? '—',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                tx['description'] ?? 'Subscription Payment',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${tx['amount'] ?? '0.00'}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: statusColor),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFFCBD5E1)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    final alerts = (_billingData?['alerts'] as List?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        if (alerts.isEmpty)
          _buildNoAlertsState()
        else
          ...alerts.map((alert) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAlertItem(
              alert['message'] ?? 'Alert',
              alert['action_text'],
              alert['type'] == 'error' ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
              alert['type'] == 'error' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
              alert['type'] == 'error' ? LucideIcons.alertCircle : LucideIcons.info,
            ),
          )),
        const SizedBox(height: 24),
        _buildUpdateBillingButton(),
      ],
    );
  }

  Widget _buildNoAlertsState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle, size: 18, color: Color(0xFF10B981)),
          SizedBox(width: 12),
          Text(
            'All good! No urgent alerts.',
            style: TextStyle(fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateBillingButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.settings, size: 16, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            const Text(
              'Update Billing Info',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String text, String? action, Color bg, Color textCol, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textCol.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textCol),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textCol, fontWeight: FontWeight.w600),
            ),
          ),
          if (action != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textCol.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                action,
                style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
