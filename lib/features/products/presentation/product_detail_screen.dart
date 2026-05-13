import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/features/products/domain/product_details.dart';
import 'package:product_db_flutter/features/products/presentation/product_detail_controller.dart';
import 'package:product_db_flutter/shared/formatters/currency_brl.dart';
import 'package:product_db_flutter/shared/formatters/date.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(productDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Product #$id')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(productDetailProvider(id)),
        ),
        data: (product) => _ProductBody(product: product),
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({required this.product});

  final ProductDetails product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(product.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        _MetaGrid(product: product),
        const SizedBox(height: 16),
        if (product.latestPrice != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest price',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (product.latestDate != null)
                      Text(
                        formatDate(product.latestDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  formatBrl(product.latestPrice!),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'PRICE HISTORY (${product.priceHistory.length})',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (product.priceHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No price history yet.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var i = 0; i < product.priceHistory.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(formatDate(product.priceHistory[i].date)),
                        const Spacer(),
                        Text(
                          formatBrl(product.priceHistory[i].value),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < product.priceHistory.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.product});

  final ProductDetails product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width / 2 - 24;
    final pills = <Widget>[
      _Pill(
        label: 'Code',
        value: product.code.isEmpty ? '—' : product.code,
      ),
      _Pill(label: 'EAN', value: product.isEan ? 'Yes' : 'No'),
      _Pill(
        label: 'Unit',
        value: '${_formatAmount(product.amount)} ${product.type}'.trim(),
      ),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: pills
          .map((w) => ConstrainedBox(
                constraints: BoxConstraints(minWidth: width),
                child: w,
              ))
          .toList(),
    );
  }

  String _formatAmount(double amount) {
    return amount == amount.truncate()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(3);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          const Text('Could not load product.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
