import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:product_db_flutter/core/permissions/camera_permission.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
  );

  StreamSubscription<BarcodeCapture>? _sub;
  CameraPermissionResult? _permission;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final result = await requestCameraPermission();
    if (!mounted) return;
    setState(() => _permission = result);
    if (result == CameraPermissionResult.granted) {
      await _startScanner();
    }
  }

  Future<void> _startScanner() async {
    _sub ??= _controller.barcodes.listen(_onCapture);
    try {
      await _controller.start();
    } on MobileScannerException catch (_) {
      // start may throw if already running or device busy; ignore.
    }
  }

  Future<void> _onCapture(BarcodeCapture capture) async {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      debugPrint('[scanner] barcode rawValue=$raw format=${barcode.format}');
      if (raw == null || raw.isEmpty) continue;
      _handled = true;
      await _controller.stop();
      if (!mounted) return;
      context
          .pushReplacement('/process?url=${Uri.encodeQueryComponent(raw)}');
      return;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_permission != CameraPermissionResult.granted) return;
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_startScanner());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_sub?.cancel());
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permission == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_permission != CameraPermissionResult.granted) {
      return _PermissionDeniedView(
        permanent: _permission == CameraPermissionResult.permanentlyDenied,
        onRetry: () async {
          setState(() => _permission = null);
          await _initialize();
        },
      );
    }
    return _ScannerView(
      controller: _controller,
      onClose: () => context.pop(),
    );
  }
}

class _ScannerView extends StatelessWidget {
  const _ScannerView({required this.controller, required this.onClose});

  final MobileScannerController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final windowSide = size.shortestSide * 0.7;
          final scanWindow = Rect.fromCenter(
            center: size.center(Offset.zero),
            width: windowSide,
            height: windowSide,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(controller: controller),
              ScanWindowOverlay(
                controller: controller,
                scanWindow: scanWindow,
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.6),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: controller,
                        builder: (context, state, _) {
                          final on = state.torchState == TorchState.on;
                          if (state.torchState == TorchState.unavailable) {
                            return const SizedBox.shrink();
                          }
                          return IconButton.filledTonal(
                            onPressed: controller.toggleTorch,
                            icon: Icon(
                              on ? Icons.flash_on : Icons.flash_off,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Point at the invoice QR code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({
    required this.permanent,
    required this.onRetry,
  });

  final bool permanent;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                'We need camera access to read the invoice QR code.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                permanent
                    ? 'Permission denied. Enable it from settings.'
                    : 'Tap "Allow" on the prompt.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (permanent)
                const FilledButton(
                  onPressed: openAppSettings,
                  child: Text('Open settings'),
                )
              else
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
