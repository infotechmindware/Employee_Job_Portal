import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../models/billing_overview_model.dart';
import 'transaction_detail_screen.dart';
import 'invoice_viewer_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> with SingleTickerProviderStateMixin {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedType = 'ALL';
  String _selectedStatus = 'All';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final from = _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null;
    final to = _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null;
    
    await ref.read(transactionsProvider.notifier).loadMore(
      from: from,
      to: to,
      status: _selectedStatus,
      method: _selectedType,
    );
  }

  void _applyFilters() {
    if (_fromDate != null && _toDate != null && _fromDate!.isAfter(_toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From Date cannot be after To Date'), backgroundColor: Colors.red),
      );
      return;
    }

    final from = _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null;
    final to = _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null;
    
    ref.read(transactionsProvider.notifier).fetchTransactions(
      from: from,
      to: to,
      status: _selectedStatus,
      method: _selectedType,
    );
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedType = 'ALL';
      _selectedStatus = 'All';
    });
    ref.read(transactionsProvider.notifier).fetchTransactions();
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
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
    final transactionsState = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, // Remove Hamburger completely
        title: const Text(
          'Transactions',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle Section: Align heading properly with safe area
            _buildHeaderSubtitle(theme),
            
            Expanded(
              child: transactionsState.data.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                error: (err, stack) => _buildErrorState(err.toString(), theme),
                data: (data) {
                  return RefreshIndicator(
                    onRefresh: () async => ref.read(transactionsProvider.notifier).fetchTransactions(),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _buildStatsGrid(data, theme),
                          const SizedBox(height: 20),
                          _buildFilterCard(theme, transactionsState.data.isLoading),
                          const SizedBox(height: 24),
                          _buildHistoryHeader(data),
                          const SizedBox(height: 12),
                          _buildTransactionList(data, transactionsState.isMoreLoading, theme),
                          const SizedBox(height: 40),
                        ],
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

  Widget _buildHeaderSubtitle(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
          ),
          const SizedBox(width: 8),
          Text(
            'Track all billing activities',
            style: TextStyle(fontSize: 12, color: const Color(0xFF1E293B).withOpacity(0.4), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(TransactionListResponse data, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildStatItem('Count', data.totalItems.toString(), LucideIcons.list, const Color(0xFF6366F1)),
        _buildStatItem('Paid', '₹${data.totalPaid.toInt()}', LucideIcons.checkCircle, const Color(0xFF10B981)),
        _buildStatItem('Pending', '₹${data.pendingAmount.toInt()}', LucideIcons.clock, const Color(0xFFF59E0B)),
        _buildStatItem('Failed', data.failedTransactions.toString(), LucideIcons.xCircle, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 14, color: color)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))),
              Text(label, style: TextStyle(fontSize: 9, color: const Color(0xFF1E293B).withOpacity(0.3), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(ThemeData theme, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInput('From Date', _fromDate, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildInput('To Date', _toDate, false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown('Type', _selectedType, ['ALL', 'Subscription', 'Addon', 'Annual', 'Monthly', 'Quarterly'], (v) => setState(() => _selectedType = v!))),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Status', _selectedStatus, ['All', 'Completed', 'Pending', 'Failed', 'Processing'], (v) => setState(() => _selectedStatus = v!))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _applyFilters,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _resetFilters,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, DateTime? date, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pure Solid Black Label
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isFrom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    date != null ? DateFormat('dd-MM-yyyy').format(date) : 'Select',
                    // Black for selected, slightly grey for placeholder
                    style: TextStyle(fontSize: 11, color: date != null ? Colors.black : Colors.grey.shade400, fontWeight: date != null ? FontWeight.w800 : FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                Icon(LucideIcons.calendar, size: 12, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pure Solid Black Label
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(LucideIcons.chevronDown, size: 12, color: Colors.grey.shade400),
              items: items.map((String item) => DropdownMenuItem<String>(
                value: item,
                // Black dropdown text
                child: Text(item, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black))
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(TransactionListResponse data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Transaction History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        Text('Showing ${data.transactions.length}/${data.totalItems}', style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildTransactionList(TransactionListResponse data, bool isMoreLoading, ThemeData theme) {
    final transactions = data.transactions;
    if (transactions.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _buildModernCard(transactions[index], theme),
        ),
        if (isMoreLoading) const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))))),
      ],
    );
  }

  Widget _buildModernCard(Transaction trx, ThemeData theme) {
    final status = (trx.status ?? 'Pending').toLowerCase();
    Color statusColor = Colors.grey;
    if (status == 'completed' || status == 'success') statusColor = const Color(0xFF10B981);
    else if (status == 'failed') statusColor = const Color(0xFFEF4444);
    else if (status == 'pending') statusColor = const Color(0xFFF59E0B);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceViewerScreen(transaction: trx))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: statusColor.withOpacity(0.08), shape: BoxShape.circle), child: Icon(_getTypeIcon(trx.description ?? ''), size: 16, color: statusColor)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trx.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text('${trx.invoiceNumber ?? '—'} • ${DateFormat('dd MMM').format(DateTime.parse(trx.createdAt!))}', style: TextStyle(fontSize: 10, color: const Color(0xFF1E293B).withOpacity(0.3), fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('₹${trx.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.fileText, size: 10, color: const Color(0xFF6366F1).withOpacity(0.3)),
                ]),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5), decoration: BoxDecoration(color: statusColor.withOpacity(0.08), borderRadius: BorderRadius.circular(4)), child: Text(status.toUpperCase(), style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: statusColor))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('Annual')) return LucideIcons.calendarCheck;
    if (type.contains('Monthly')) return LucideIcons.calendar;
    return LucideIcons.creditCard;
  }

  Widget _buildEmptyState() {
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(LucideIcons.searchX, size: 36, color: const Color(0xFF1E293B).withOpacity(0.1)), const SizedBox(height: 12), const Text('No results', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)))]));
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(LucideIcons.alertCircle, size: 36, color: Colors.red), const SizedBox(height: 12), Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), TextButton(onPressed: () => ref.read(transactionsProvider.notifier).fetchTransactions(), child: const Text('Retry'))]));
  }
}
