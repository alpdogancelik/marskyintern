import 'package:flutter_test/flutter_test.dart';
import 'package:marsky/app/router.dart';
import 'package:marsky/features/auth/domain/auth_state.dart';

void main() {
  group('resolveAppAuthRedirect', () {
    test('redirects logged-out users from protected routes to login', () {
      final redirect = resolveAppAuthRedirect(
        location: '/app/home',
        authState: const AuthState.unauthenticated(),
      );

      expect(redirect, '/auth/login');
    });

    test('allows logged-out users on auth routes', () {
      final redirect = resolveAppAuthRedirect(
        location: '/auth/login',
        authState: const AuthState.unauthenticated(),
      );

      expect(redirect, isNull);
    });

    test('redirects logged-in users away from auth routes', () {
      final redirect = resolveAppAuthRedirect(
        location: '/auth/login',
        authState: const AuthState.authenticated('user-1'),
      );

      expect(redirect, '/app/home');
    });

    test('allows logged-in users on protected routes', () {
      final redirect = resolveAppAuthRedirect(
        location: '/wallet',
        authState: const AuthState.authenticated('user-1'),
      );

      expect(redirect, isNull);
    });

    test('redirects authenticated users away from splash route', () {
      final redirect = resolveAppAuthRedirect(
        location: '/splash',
        authState: const AuthState.authenticated('user-1'),
      );

      expect(redirect, '/app/home');
    });
  });
}
