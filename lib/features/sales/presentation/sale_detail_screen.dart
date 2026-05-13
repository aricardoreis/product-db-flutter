import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/features/sales/domain/sale_details.dart';
import 'package:product_db_flutter/features/sales/presentation/sale_detail_controller.dart';
import 'package:product_db_flutter/shared/formatters/currency_brl.dart';
import 'package:product_db_flutter/shared/formatters/date.dart';

class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(saleDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Sale #$id')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(saleDetailProvider(id)),
        ),
        data: (sale) => _SaleBody(sale: sale),
      ),
    );
  }
}

class _SaleBody extends StatelessWidget {
  const _SaleBody({required this.sale});

  final SaleDetails sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Store',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sale.store.name, style: theme.textTheme.titleMedium),
              if (sale.store.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  sale.store.address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Date',
          child: Text(formatDate(sale.date), style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Products (${sale.products.length})',
          child: Column(
            children: [
              for (final p in sale.products) ...[
                _ProductLine(line: p),
                if (p != sale.products.last)
                  const Divider(height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text('Total', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                formatBrl(sale.total),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ProductLine extends StatelessWidget {
  const _ProductLine({required this.line});

  final SaleProductLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = _formatQty(line.amount, line.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  '$qty × ${formatBrl(line.value)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatBrl(line.lineTotal),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatQty(double amount, String type) {
    final str = amount == amount.truncate()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(3);
    return type.isEmpty ? str : '$str $type';
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
          const Text('Could not load sale.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
