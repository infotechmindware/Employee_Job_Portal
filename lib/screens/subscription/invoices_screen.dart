import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _selectedStatus = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allInvoices = [
    {
      'id': 'INV-202605-F86372',
      'date': DateTime(2026, 5, 1),
      'cycle': 'Monthly',
      'amount': 850.00,
      'status': 'Completed',
    },
    {
      'id': 'INV-173',
      'date': DateTime(2026, 5, 1),
      'cycle': 'Monthly',
      'amount': 400.00,
      'status': 'Pending',
    },
    {
      'id': 'INV-172',
      'date': DateTime(2026, 4, 30),
      'cycle': 'Annual',
      'amount': 8500.00,
      'status': 'Pending',
    },
    {
      'id': 'INV-171',
      'date': DateTime(2026, 4, 15),
      'cycle': 'Monthly',
      'amount': 850.00,
      'status': 'Failed',
    },
  ];

  List<Map<String, dynamic>> _filteredInvoices = [];

  @override
  void initState() {
    super.initState();
    _filteredInvoices = List.from(_allInvoices);
  }

  void _applyFilter() {
    setState(() {
      _filteredInvoices = _allInvoices.where((inv) {
        final matchesStatus = _selectedStatus == 'All' || inv['status'] == _selectedStatus;
        final matchesDate = (_startDate == null || inv['date'].isAfter(_startDate!)) &&
            (_endDate == null || inv['date'].isBefore(_endDate!.add(const Duration(days: 1))));
        final matchesSearch = _searchController.text.isEmpty || 
            inv['id'].toLowerCase().contains(_searchController.text.toLowerCase());
        return matchesStatus && matchesDate && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF6B7280)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Back to Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Page Header
            const Text('Invoices', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF111827), letterSpacing: -1.0)),
            const SizedBox(height: 8),
            const Text('View and manage your billing history, payments, and subscriptions.', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), fontWeight: FontWeight.w400)),
            const SizedBox(height: 40),
            
            _buildSummaryStats(isDesktop),
            const SizedBox(height: 48),
            
            _buildMainContent(isDesktop),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(bool isDesktop) {
    final totalInvoices = _allInvoices.length;
    final totalPaid = _allInvoices.where((i) => i['status'] == 'Completed').fold(0.0, (sum, i) => sum + i['amount']);
    final pendingCount = _allInvoices.where((i) => i['status'] == 'Pending').length;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('Total Invoices', totalInvoices.toString(), LucideIcons.fileText)),
          const SizedBox(width: 24),
          Expanded(child: _buildStatCard('Amount Paid', '₹${NumberFormat('#,##0').format(totalPaid)}', LucideIcons.checkCircle2)),
          const SizedBox(width: 24),
          Expanded(child: _buildStatCard('Pending Invoices', pendingCount.toString(), LucideIcons.clock)),
        ],
      );
    }

    return Column(
      children: [
        _buildStatCard('Total Invoices', totalInvoices.toString(), LucideIcons.fileText),
        const SizedBox(height: 16),
        _buildStatCard('Amount Paid', '₹${NumberFormat('#,##0').format(totalPaid)}', LucideIcons.checkCircle2),
        const SizedBox(height: 16),
        _buildStatCard('Pending Invoices', pendingCount.toString(), LucideIcons.clock),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                const SizedBox(height: 12),
                Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827), letterSpacing: -0.5)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF9CA3AF), size: 24),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableActions(isDesktop),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildInvoicesTable(isDesktop),
        ],
      ),
    );
  }

  Widget _buildTableActions(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF13489C), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          // Status Filter
          _buildStatusDropdown(),
          // Date Filter Button
          _buildDateRangeTrigger(),
          // Reset Filter
          if (_selectedStatus != 'All' || _startDate != null || _searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedStatus = 'All';
                  _startDate = null;
                  _endDate = null;
                  _applyFilter();
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeTrigger() {
    return InkWell(
      onTap: () async {
        final dateRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF13489C))),
            child: child!,
          ),
        );
        if (dateRange != null) {
          setState(() {
            _startDate = dateRange.start;
            _endDate = dateRange.end;
            _applyFilter();
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              _startDate == null ? 'Date' : '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
          borderRadius: BorderRadius.circular(8),
          items: ['All', 'Completed', 'Pending', 'Failed']
              .map((s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? 'Status' : s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)))))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedStatus = val!;
              _applyFilter();
            });
          },
        ),
      ),
    );
  }

  Widget _buildInvoicesTable(bool isDesktop) {
    if (_filteredInvoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(60.0),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.inbox, size: 48, color: const Color(0xFFD1D5DB)),
              const SizedBox(height: 16),
              const Text('No invoices found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 52,
          dataRowHeight: 68,
          horizontalMargin: 24,
          columnSpacing: 48,
          dividerThickness: 1,
          headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.5),
          columns: const [
            DataColumn(label: Text('INVOICE')),
            DataColumn(label: Text('AMOUNT')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('')),
          ],
          rows: _filteredInvoices.map((inv) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(inv['id'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(inv['cycle'], style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                DataCell(Text('₹${NumberFormat('#,##0.00').format(inv['amount'])}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)))),
                DataCell(Text(DateFormat('MMM d, yyyy').format(inv['date']), style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
                DataCell(_buildStatusBadge(inv['status'])),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionIcon(LucideIcons.fileText, 'View', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: inv)));
                      }),
                      const SizedBox(width: 8),
                      _buildActionIcon(LucideIcons.download, 'Download', () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: inv)));
                      }),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: const Color(0xFFF3F4F6),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Completed':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        break;
      case 'Pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'Failed':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
