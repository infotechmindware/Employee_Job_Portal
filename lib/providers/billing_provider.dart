import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';
import '../models/billing_overview_model.dart';

final billingOverviewProvider = NotifierProvider<BillingOverviewNotifier, AsyncValue<BillingOverview>>(BillingOverviewNotifier.new);

class BillingOverviewNotifier extends Notifier<AsyncValue<BillingOverview>> {
  @override
  AsyncValue<BillingOverview> build() {
    Future.microtask(() => fetchBillingOverview());
    return const AsyncValue.loading();
  }

  Future<void> fetchBillingOverview() async {
    state = const AsyncValue.loading();
    try {
      final response = await SubscriptionService.getBillingOverview();
      if (response['success']) {
        state = AsyncValue.data(BillingOverview.fromJson(response['data']));
      } else {
        state = AsyncValue.error(response['message'] ?? 'Failed to fetch billing data', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final response = await SubscriptionService.getBillingOverview();
      if (response['success']) {
        state = AsyncValue.data(BillingOverview.fromJson(response['data']));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Updated State for Transactions to include loading flags
class TransactionsState {
  final AsyncValue<TransactionListResponse> data;
  final bool isMoreLoading;

  TransactionsState({
    required this.data,
    this.isMoreLoading = false,
  });

  TransactionsState copyWith({
    AsyncValue<TransactionListResponse>? data,
    bool? isMoreLoading,
  }) {
    return TransactionsState(
      data: data ?? this.data,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
    );
  }
}

final transactionsProvider = NotifierProvider<TransactionListNotifier, TransactionsState>(TransactionListNotifier.new);

class TransactionListNotifier extends Notifier<TransactionsState> {
  @override
  TransactionsState build() {
    Future.microtask(() => fetchTransactions());
    return TransactionsState(data: const AsyncValue.loading());
  }

  Future<void> fetchTransactions({
    String? from,
    String? to,
    String? status,
    String? method,
    String? product,
  }) async {
    state = state.copyWith(data: const AsyncValue.loading(), isMoreLoading: false);
    try {
      final response = await SubscriptionService.getTransactions(
        from: from,
        to: to,
        status: status,
        method: method,
        product: product,
        page: 1,
      );
      if (response['success']) {
        state = state.copyWith(data: AsyncValue.data(TransactionListResponse.fromJson(response['data'])));
      } else {
        state = state.copyWith(data: AsyncValue.error(response['message'] ?? 'Failed to fetch transactions', StackTrace.current));
      }
    } catch (e, stack) {
      state = state.copyWith(data: AsyncValue.error(e, stack));
    }
  }

  Future<void> loadMore({
    String? from,
    String? to,
    String? status,
    String? method,
    String? product,
  }) async {
    // Prevent double calls
    if (state.isMoreLoading || !state.data.hasValue) return;
    
    final currentData = state.data.value!;
    if (currentData.currentPage >= currentData.totalPages) return;

    state = state.copyWith(isMoreLoading: true);
    
    try {
      final response = await SubscriptionService.getTransactions(
        from: from,
        to: to,
        status: status,
        method: method,
        product: product,
        page: currentData.currentPage + 1,
      );

      if (response['success']) {
        final newData = TransactionListResponse.fromJson(response['data']);
        
        final existingIds = currentData.transactions.map((t) => t.id).toSet();
        final filteredNewTransactions = newData.transactions.where((t) => !existingIds.contains(t.id)).toList();

        state = state.copyWith(
          isMoreLoading: false,
          data: AsyncValue.data(TransactionListResponse(
            totalTransactions: newData.totalTransactions,
            totalPaid: newData.totalPaid,
            pendingAmount: newData.pendingAmount,
            failedTransactions: newData.failedTransactions,
            transactions: [...currentData.transactions, ...filteredNewTransactions],
            currentPage: newData.currentPage,
            totalPages: newData.totalPages,
            totalItems: newData.totalItems,
          )),
        );
      } else {
        state = state.copyWith(isMoreLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isMoreLoading: false);
      debugPrint('❌ [Transactions] Load more error: $e');
    }
  }
}
