import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedType = 'ALL';
  String _selectedStatus = 'All';
  bool _isFiltering = false;

  // Mock Data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 'TRX-98231',
      'amount': 2500.00,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'UPI',
      'gateway': 'RAZORPAY',
      'status': 'Completed',
      'customer': 'John Doe',
    },
    {
      'id': 'TRX-98232',
      'amount': 1200.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'CARD',
      'gateway': 'STRIPE',
      'status': 'Failed',
      'customer': 'Jane Smith',
    },
    {
      'id': 'TRX-98233',
      'amount': 5000.00,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'NETBANKING',
      'gateway': 'PAYU',
      'status': 'Pending',
      'customer': 'Mike Ross',
    },
    {
      'id': 'TRX-98234',
      'amount': 750.00,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'WALLET',
      'gateway': 'CASHFREE',
      'status': 'Refunded',
      'customer': 'Harvey Specter',
    },
    {
      'id': 'TRX-98235',
      'amount': 3200.00,
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'type': 'UPI',
      'gateway': 'PAYTM',
      'status': 'Completed',
      'customer': 'Louis Litt',
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
  }

  void _applyFilters() {
    setState(() => _isFiltering = true);
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _filteredTransactions = _allTransactions.where((trx) {
          final date = trx['date'] as DateTime;
          final type = trx['type'] as String;
          final status = trx['status'] as String;
          final gateway = trx['gateway'] as String;
          
          bool matchesDate = true;
          if (_fromDate != null) {
            matchesDate = date.isAfter(_fromDate!.subtract(const Duration(seconds: 1)));
          }
          if (_toDate != null) {
            matchesDate = matchesDate && date.isBefore(_toDate!.add(const Duration(days: 1)));
          }
          
          bool matchesType = _selectedType == 'ALL' || type == _selectedType || gateway == _selectedType;
          bool matchesStatus = _selectedStatus == 'All' || status == _selectedStatus;
          
          return matchesDate && matchesType && matchesStatus;
        }).toList();
        _isFiltering = false;
      });
    });
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedType = 'ALL';
      _selectedStatus = 'All';
      _filteredTransactions = List.from(_allTransactions);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            _buildStatsGrid(isDesktop, theme),
            const SizedBox(height: 32),
            _buildFiltersCard(isDesktop, theme),
            const SizedBox(height: 32),
            _buildTransactionsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.wallet, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Live',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Track all your billing activities',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isDesktop, ThemeData theme) {
    final stats = [
      {'title': 'Total Transactions', 'value': _allTransactions.length.toString(), 'icon': LucideIcons.list, 'color': const Color(0xFF6366F1)},
      {'title': 'Total Paid', 'value': '₹${_allTransactions.where((t) => t['status'] == 'Completed').fold(0.0, (sum, item) => sum + item['amount']).toStringAsFixed(2)}', 'icon': LucideIcons.checkCircle, 'color': const Color(0xFF10B981)},
      {'title': 'Pending Amount', 'value': '₹${_allTransactions.where((t) => t['status'] == 'Pending').fold(0.0, (sum, item) => sum + item['amount']).toStringAsFixed(2)}', 'icon': LucideIcons.clock, 'color': const Color(0xFFF59E0B)},
      {'title': 'Failed Transactions', 'value': _allTransactions.where((t) => t['status'] == 'Failed').length.toString(), 'icon': LucideIcons.xCircle, 'color': const Color(0xFFEF4444)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isDesktop ? 1.4 : 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index], theme),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, ThemeData theme) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(stat['icon'] as IconData, size: 20, color: color),
              ),
              Icon(LucideIcons.trendingUp, size: 14, color: color.withOpacity(0.4)),
            ],
          ),
          const Spacer(),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(bool isDesktop, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.filter, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Filter Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 400;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInput(
                          'From Date',
                          _fromDate == null ? 'dd-mm-yyyy' : DateFormat('dd MMM, yyyy').format(_fromDate!),
                          LucideIcons.calendar,
                          () => _selectDate(context, true),
                          theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateInput(
                          'To Date',
                          _toDate == null ? 'dd-mm-yyyy' : DateFormat('dd MMM, yyyy').format(_toDate!),
                          LucideIcons.calendar,
                          () => _selectDate(context, false),
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdownField('Type', _selectedType, [
                        'ALL', 'CARD', 'UPI', 'NETBANKING', 'WALLET', 'RAZORPAY', 'STRIPE', 'PAYU', 'CASHFREE', 'PAYTM'
                      ], (val) => setState(() => _selectedType = val), theme)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownField('Status', _selectedStatus, [
                        'All', 'Completed', 'Failed', 'Pending', 'Refunded'
                      ], (val) => setState(() => _selectedStatus = val), theme)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isFiltering ? null : _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isFiltering 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Apply Filters',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _resetFilters,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(String label, String value, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.contains('dd') ? theme.colorScheme.onSurface.withOpacity(0.3) : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String) onChanged, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCustomPicker(label, items, value, onChanged, theme),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (value != 'ALL' && value != 'All') ...[
                        Icon(_getOptionIcon(value), size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomPicker(String title, List<String> items, String selectedValue, Function(String) onSelect, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, -10)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.listFilter, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        onSelect(item);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : theme.dividerColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getOptionIcon(item),
                                size: 14,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(LucideIcons.check, size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOptionIcon(String option) {
    switch (option.toUpperCase()) {
      case 'ALL': return LucideIcons.list;
      case 'CARD': return LucideIcons.creditCard;
      case 'UPI': return LucideIcons.smartphone;
      case 'NETBANKING': return LucideIcons.landmark;
      case 'WALLET': return LucideIcons.wallet;
      case 'RAZORPAY': return LucideIcons.shieldCheck;
      case 'STRIPE': return LucideIcons.zap;
      case 'PAYU': return LucideIcons.pocket;
      case 'CASHFREE': return LucideIcons.banknote;
      case 'PAYTM': return LucideIcons.smartphone;
      case 'COMPLETED': return LucideIcons.checkCircle;
      case 'FAILED': return LucideIcons.xCircle;
      case 'PENDING': return LucideIcons.clock;
      case 'REFUNDED': return LucideIcons.refreshCcw;
      default: return LucideIcons.moreHorizontal;
    }
  }

  Widget _buildTransactionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
            ),
            Text(
              '${_filteredTransactions.length} results',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _filteredTransactions.isEmpty 
          ? _buildEmptyState(theme)
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final trx = _filteredTransactions[index];
                return _buildTransactionCard(trx, theme);
              },
            ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> trx, ThemeData theme) {
    final status = trx['status'] as String;
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed': statusColor = const Color(0xFF10B981); break;
      case 'failed': statusColor = const Color(0xFFEF4444); break;
      case 'pending': statusColor = const Color(0xFFF59E0B); break;
      case 'refunded': statusColor = const Color(0xFF6366F1); break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(trx['type']),
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trx['customer'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trx['type']} • ${DateFormat('dd MMM, hh:mm a').format(trx['date'])}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${trx['amount'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CARD': return LucideIcons.creditCard;
      case 'UPI': return LucideIcons.smartphone;
      case 'WALLET': return LucideIcons.wallet;
      case 'NETBANKING': return LucideIcons.landmark;
      default: return LucideIcons.banknote;
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.searchX, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search keywords to find what you are looking for.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4), height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _resetFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }
}
