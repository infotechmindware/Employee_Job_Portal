import 'dart:convert';

class BillingOverview {
  final String? currentPlan;
  final Map<String, dynamic>? subscription;
  final double balanceDue;
  final String? upcomingDate;
  final double? upcomingAmount;
  final LastPayment? lastPayment;
  final List<Transaction> recentTransactions;
  final List<Invoice> invoices;
  final List<BillingAlert> alerts;

  BillingOverview({
    this.currentPlan,
    this.subscription,
    required this.balanceDue,
    this.upcomingDate,
    this.upcomingAmount,
    this.lastPayment,
    required this.recentTransactions,
    required this.invoices,
    required this.alerts,
  });

  factory BillingOverview.fromJson(Map<String, dynamic> json) {
    String? parsePlan(dynamic plan) {
      if (plan == null) return null;
      if (plan is String) return plan;
      if (plan is Map) return plan['name']?.toString() ?? plan['title']?.toString();
      return plan.toString();
    }

    return BillingOverview(
      currentPlan: parsePlan(json['current_plan']),
      subscription: json['subscription'] is Map ? json['subscription'] : null,
      balanceDue: _toDouble(json['balance_due']),
      upcomingDate: json['upcoming_date']?.toString(),
      upcomingAmount: _toDouble(json['upcoming_amount']),
      lastPayment: json['last_payment'] != null ? LastPayment.fromJson(json['last_payment']) : null,
      recentTransactions: (json['recent_transactions'] as List? ?? [])
          .map((e) => Transaction.fromJson(e))
          .toList(),
      invoices: (json['invoices'] as List? ?? [])
          .map((e) => Invoice.fromJson(e))
          .toList(),
      alerts: (json['alerts'] as List? ?? [])
          .map((e) => BillingAlert.fromJson(e))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class LastPayment {
  final double amount;
  final String? createdAt;
  final String? status;

  LastPayment({
    required this.amount,
    this.createdAt,
    this.status,
  });

  factory LastPayment.fromJson(Map<String, dynamic> json) {
    return LastPayment(
      amount: BillingOverview._toDouble(json['amount']),
      createdAt: json['created_at'],
      status: json['status'],
    );
  }
}

class Transaction {
  final String? id;
  final String? gatewayPaymentId;
  final String? gatewayOrderId;
  final double amount;
  final String? currency;
  final String? billingCycle;
  final String? gateway;
  final String? status;
  final String? createdAt;
  final String? paidAt;
  final String? invoiceNumber;
  final String? invoiceUrl;
  final String? kind;
  final double? refundAmount;
  final String? failureReason;

  Transaction({
    this.id,
    this.gatewayPaymentId,
    this.gatewayOrderId,
    required this.amount,
    this.currency,
    this.billingCycle,
    this.gateway,
    this.status,
    this.createdAt,
    this.paidAt,
    this.invoiceNumber,
    this.invoiceUrl,
    this.kind,
    this.refundAmount,
    this.failureReason,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      gatewayPaymentId: json['gateway_payment_id']?.toString(),
      gatewayOrderId: json['gateway_order_id']?.toString(),
      amount: BillingOverview._toDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'INR',
      billingCycle: json['billing_cycle']?.toString(),
      gateway: json['gateway']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
      paidAt: json['paid_at']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      invoiceUrl: json['invoice_url']?.toString(),
      kind: json['kind']?.toString(),
      refundAmount: BillingOverview._toDouble(json['refund_amount']),
      failureReason: json['failure_reason']?.toString(),
    );
  }

  String get title {
    if (kind != null && billingCycle != null) {
      return '${kind![0].toUpperCase()}${kind!.substring(1)} • ${billingCycle![0].toUpperCase()}${billingCycle!.substring(1)}';
    }
    return kind ?? 'Subscription Payment';
  }

  // Backward compatibility
  String? get description => title;
  String? get date => createdAt;
}

class Invoice {
  final String? id;
  final String? invoiceNumber;
  final double amount;
  final String? date;
  final String? status;
  final String? pdfUrl;

  Invoice({
    this.id,
    this.invoiceNumber,
    required this.amount,
    this.date,
    this.status,
    this.pdfUrl,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString(),
      invoiceNumber: (json['invoice_number'] ?? json['number'])?.toString(),
      amount: BillingOverview._toDouble(json['amount']),
      date: (json['date'] ?? json['created_at'])?.toString(),
      status: json['status']?.toString(),
      pdfUrl: (json['pdf_url'] ?? json['download_url'])?.toString(),
    );
  }
}

class BillingAlert {
  final String message;
  final String? actionText;
  final String type; // error, warning, info

  BillingAlert({
    required this.message,
    this.actionText,
    required this.type,
  });

  factory BillingAlert.fromJson(Map<String, dynamic> json) {
    return BillingAlert(
      message: json['message'] ?? 'Billing alert',
      actionText: json['action_text'],
      type: json['type'] ?? 'info',
    );
  }
}

class TransactionListResponse {
  final int totalTransactions;
  final double totalPaid;
  final double pendingAmount;
  final int failedTransactions;
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  TransactionListResponse({
    required this.totalTransactions,
    required this.totalPaid,
    required this.pendingAmount,
    required this.failedTransactions,
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    final pagination = json['pagination'] ?? {};
    return TransactionListResponse(
      totalTransactions: summary['total'] ?? 0,
      totalPaid: BillingOverview._toDouble(summary['paid']),
      pendingAmount: BillingOverview._toDouble(summary['pending']),
      failedTransactions: summary['failed'] ?? 0,
      transactions: (json['rows'] as List? ?? [])
          .map((e) => Transaction.fromJson(e))
          .toList(),
      currentPage: pagination['current_page'] ?? 1,
      totalPages: pagination['total_pages'] ?? 1,
      totalItems: pagination['total'] ?? 0,
    );
  }
}
