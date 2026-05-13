import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/features/sales/data/sales_api.dart';
import 'package:product_db_flutter/features/sales/domain/sale.dart';

class SalesListState {
  const SalesListState({
    this.items = const [],
    this.totalCount = 0,
    this.nextPage = 1,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Sale> items;
  final int totalCount;
  final int nextPage;
  final bool loadingMore;
  final bool hasMore;
  final Object? error;

  bool get isInitialLoad => items.isEmpty && loadingMore && error == null;
  bool get isEmpty => items.isEmpty && !loadingMore && error == null;

  SalesListState copyWith({
    List<Sale>? items,
    int? totalCount,
    int? nextPage,
    bool? loadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) =>
      SalesListState(
        items: items ?? this.items,
        totalCount: totalCount ?? this.totalCount,
        nextPage: nextPage ?? this.nextPage,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class SalesListController extends Notifier<SalesListState> {
  static const _limit = 20;

  @override
  SalesListState build() {
    unawaited(Future.microtask(loadNext));
    return const SalesListState(loadingMore: true);
  }

  Future<void> loadNext() async {
    if (state.loadingMore && state.items.isNotEmpty) return;
    if (!state.hasMore) return;

    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final page = await ref
          .read(salesApiProvider)
          .list(page: state.nextPage, limit: _limit);
      final newItems = [...state.items, ...page.items];
      state = state.copyWith(
        items: newItems,
        totalCount: page.total,
        nextPage: state.nextPage + 1,
        loadingMore: false,
        hasMore: newItems.length < page.total && page.items.isNotEmpty,
      );
    } on Object catch (e) {
      state = state.copyWith(loadingMore: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = const SalesListState(loadingMore: true);
    await loadNext();
  }
}

final salesListControllerProvider =
    NotifierProvider<SalesListController, SalesListState>(
  SalesListController.new,
);
