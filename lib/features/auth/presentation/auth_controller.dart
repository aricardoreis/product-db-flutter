import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/features/auth/data/auth_repository.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

sealed class AuthState {
  const AuthState();
}

class SignedIn extends AuthState {
  const SignedIn(this.session);
  final Session session;
}

class SignedOut extends AuthState {
  const SignedOut();
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final session = await ref.read(authRepositoryProvider).restore();
    return session == null ? const SignedOut() : SignedIn(session);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      return SignedIn(session);
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(SignedOut());
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);
