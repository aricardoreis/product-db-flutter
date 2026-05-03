import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:product_db_flutter/features/auth/presentation/auth_controller.dart';
import 'package:product_db_flutter/features/auth/presentation/login_screen.dart';
import 'package:product_db_flutter/features/auth/presentation/splash_screen.dart';

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
      if (loc == '/splash') return signedIn ? '/' : '/login';
      if (!signedIn && loc != '/login') return '/login';
      if (signedIn && loc == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, _) => const _HomePlaceholder()),
    ],
  );
});

class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product DB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Signed in. Phase 2 begins here.')),
    );
  }
}
