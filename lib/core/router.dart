import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_db_flutter/core/shell/app_shell.dart';
import 'package:product_db_flutter/features/auth/presentation/auth_controller.dart';
import 'package:product_db_flutter/features/auth/presentation/login_screen.dart';
import 'package:product_db_flutter/features/auth/presentation/splash_screen.dart';
import 'package:product_db_flutter/features/products/presentation/product_detail_screen.dart';
import 'package:product_db_flutter/features/products/presentation/products_list_screen.dart';
import 'package:product_db_flutter/features/sales/presentation/sale_detail_screen.dart';
import 'package:product_db_flutter/features/sales/presentation/sales_list_screen.dart';
import 'package:product_db_flutter/features/scanner/presentation/processing_screen.dart';
import 'package:product_db_flutter/features/scanner/presentation/scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authControllerProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      if (auth.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      final signedIn = auth.value is SignedIn;
      if (loc == '/splash') return signedIn ? '/sales' : '/login';
      if (!signedIn && loc != '/login') return '/login';
      if (signedIn && loc == '/login') return '/sales';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/scan',
        builder: (_, _) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/process',
        builder: (_, state) => ProcessingScreen(
          url: state.uri.queryParameters['url'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (_, _) => const SalesListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => SaleDetailScreen(
                      id: state.pathParameters['id'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (_, _) => const ProductsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => ProductDetailScreen(
                      id: int.parse(state.pathParameters['id'] ?? '0'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
