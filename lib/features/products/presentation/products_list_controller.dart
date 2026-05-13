import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/features/products/data/products_api.dart';
import 'package:product_db_flutter/features/products/domain/product.dart';

class ProductsListState {
  const ProductsListState({
    this.items = const [],
    this.totalCount = 0,
    this.nextPage = 1,
    this.loadingMore = false,
    this.hasMore = true,
    this.keyword = '',
    this.error,
  });

  final List<Product> items;
  final int totalCount;
  final int nextPage;
  final bool loadingMore;
  final bool hasMore;
  final String keyword;
  final Object? error;

  bool get isInitialLoad => items.isEmpty && loadingMore && error == null;
  bool get isEmpty => items.isEmpty && !loadingMore && error == null;

  ProductsListState copyWith({
    List<Product>? items,
    int? totalCount,
    int? nextPage,
    bool? loadingMore,
    bool? hasMore,
    String? keyword,
    Object? error,
    bool clearError = false,
  }) =>
      ProductsListState(
        items: items ?? this.items,
        totalCount: totalCount ?? this.totalCount,
        nextPage: nextPage ?? this.nextPage,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        keyword: keyword ?? this.keyword,
        error: clearError ? null : (error ?? this.error),
      );
}

class ProductsListController extends Notifier<ProductsListState> {
  static const _limit = 20;
  static const _debounce = Duration(milliseconds: 400);

  Timer? _debounceTimer;
  int _searchToken = 0;

  @override
  ProductsListState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    unawaited(Future.microtask(loadNext));
    return const ProductsListState(loadingMore: true);
  }

  void setKeyword(String keyword) {
    final next = keyword.trim();
    if (next == state.keyword) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      unawaited(_resetAndLoad(next));
    });
  }

  Future<void> _resetAndLoad(String keyword) async {
    final token = ++_searchToken;
    state = ProductsListState(keyword: keyword, loadingMore: true);
    await _fetch(token: token, page: 1);
  }

  Future<void> loadNext() async {
    if (state.loadingMore && state.items.isNotEmpty) return;
    if (!state.hasMore) return;
    final token = _searchToken;
    state = state.copyWith(loadingMore: true, clearError: true);
    await _fetch(token: token, page: state.nextPage);
  }

  Future<void> _fetch({required int token, required int page}) async {
    try {
      final result = await ref.read(productsApiProvider).list(
            page: page,
            limit: _limit,
            keyword: state.keyword,
          );
      if (token != _searchToken) return; // stale response
      final mergedItems = page == 1
          ? result.items
          : [...state.items, ...result.items];
      state = state.copyWith(
        items: mergedItems,
        totalCount: result.total,
        nextPage: page + 1,
        loadingMore: false,
        hasMore: mergedItems.length < result.total && result.items.isNotEmpty,
      );
    } on Object catch (e) {
      if (token != _searchToken) return;
      state = state.copyWith(loadingMore: false, error: e);
    }
  }

  Future<void> refresh() async {
    final token = ++_searchToken;
    state = ProductsListState(keyword: state.keyword, loadingMore: true);
    await _fetch(token: token, page: 1);
  }
}

final productsListControllerProvider =
    NotifierProvider<ProductsListController, ProductsListState>(
  ProductsListController.new,
);
