import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_db_flutter/core/http/dio_client.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({required this.url, super.key});

  final String url;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  CancelToken? _cancelToken;
  Object? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    unawaited(_submit());
  }

  Future<void> _submit() async {
    if (widget.url.isEmpty) {
      setState(() => _error = 'Empty URL.');
      return;
    }
    setState(() {
      _error = null;
      _done = false;
    });
    final token = _cancelToken = CancelToken();
    try {
      await ref.read(dioProvider).post<dynamic>(
            '/sales',
            data: {'url': widget.url},
            cancelToken: token,
          );
      if (!mounted) return;
      setState(() => _done = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice processed!')),
      );
      context.go('/sales');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      if (!mounted) return;
      setState(() => _error = _humanize(e));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  String _humanize(DioException e) {
    final code = e.response?.statusCode;
    return switch (code) {
      401 => 'Session expired. Please sign in again.',
      409 => 'This invoice has already been processed.',
      404 => 'Invoice not found on the server.',
      null => 'Network failure.',
      _ => 'Backend responded with $code.',
    };
  }

  void _cancel() {
    _cancelToken?.cancel('user-cancelled');
    context.pop();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Processing invoice')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error == null && !_done) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 24),
                Text(
                  'Sending to the server…',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ] else if (_error != null) ...[
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error == null && !_done)
                OutlinedButton(
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                )
              else if (_error != null) ...[
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
