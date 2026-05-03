import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_db_flutter/features/auth/data/auth_repository.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';
import 'package:product_db_flutter/features/auth/presentation/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _session = Session(
  accessToken: 'a',
  refreshToken: 'r',
  tokenType: 'bearer',
  expiresAt: 1,
);

ProviderContainer _container(AuthRepository repo) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  group('build (initial state)', () {
    test('resolves to SignedOut when storage is empty', () async {
      when(() => repo.restore()).thenAnswer((_) async => null);
      final container = _container(repo);

      final state = await container.read(authControllerProvider.future);

      expect(state, isA<SignedOut>());
    });

    test('resolves to SignedIn when storage has a session', () async {
      when(() => repo.restore()).thenAnswer((_) async => _session);
      final container = _container(repo);

      final state = await container.read(authControllerProvider.future);

      expect(state, isA<SignedIn>());
      expect((state as SignedIn).session, _session);
    });
  });

  group('signIn', () {
    test('transitions to SignedIn on success', () async {
      when(() => repo.restore()).thenAnswer((_) async => null);
      when(() => repo.signIn(email: 'e', password: 'p'))
          .thenAnswer((_) async => _session);
      final container = _container(repo);
      await container.read(authControllerProvider.future); // settle build

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'e', password: 'p');

      final state = container.read(authControllerProvider);
      expect(state.value, isA<SignedIn>());
      expect((state.value! as SignedIn).session, _session);
    });

    test('exposes AsyncError on failure', () async {
      when(() => repo.restore()).thenAnswer((_) async => null);
      when(
        () => repo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('bad creds'));
      final container = _container(repo);
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'e', password: 'p');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });
  });

  group('signOut', () {
    test('clears repo and resets state to SignedOut', () async {
      when(() => repo.restore()).thenAnswer((_) async => _session);
      when(() => repo.signOut()).thenAnswer((_) async {});
      final container = _container(repo);
      await container.read(authControllerProvider.future);

      await container.read(authControllerProvider.notifier).signOut();

      final state = container.read(authControllerProvider);
      expect(state.value, isA<SignedOut>());
      verify(() => repo.signOut()).called(1);
    });
  });
}
