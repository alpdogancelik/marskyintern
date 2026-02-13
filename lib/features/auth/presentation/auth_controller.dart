import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/exception_mapper.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../data/auth_repository.dart';
import '../domain/entities/auth_action_result.dart';
import '../domain/entities/auth_view_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthViewState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthViewState> {
  StreamSubscription<AuthState>? _subscription;

  @override
  AuthViewState build() {
    final repository = ref.watch(authRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.sessionStream.listen(_handleAuthChange);
    ref.onDispose(() => _subscription?.cancel());

    final user = repository.currentUser;
    if (user == null) {
      return AuthViewState.unauthenticated();
    }
    return AuthViewState.authenticated(user);
  }

  Future<AuthActionResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = AuthViewState.authenticating(user: state.user);
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      final user = response.user ?? repository.currentUser;
      if (user == null) {
        const message = 'Unable to authenticate. Please try again.';
        state = AuthViewState.error(message: message);
        return AuthActionResult.failure(message);
      }

      state = AuthViewState.authenticated(user);
      return AuthActionResult.success();
    } catch (error) {
      final message = ExceptionMapper.map(error).message;
      state = AuthViewState.error(message: message, user: state.user);
      return AuthActionResult.failure(message);
    }
  }

  Future<AuthActionResult> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    state = AuthViewState.authenticating(user: state.user);
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.signUpWithEmailPassword(
        email: email,
        password: password,
        data: data,
      );
      final user = response.user ?? repository.currentUser;
      final session = response.session ?? repository.currentSession;

      if (session == null || user == null) {
        const message =
            'Account created. Please verify your email before signing in.';
        state = AuthViewState.unauthenticated(message: message);
        return AuthActionResult.requiresVerification(message: message);
      }

      state = AuthViewState.authenticated(user);
      return AuthActionResult.success();
    } catch (error) {
      final message = ExceptionMapper.map(error).message;
      state = AuthViewState.error(message: message, user: state.user);
      return AuthActionResult.failure(message);
    }
  }

  Future<AuthActionResult> resetPassword({
    required String email,
  }) async {
    state = AuthViewState.authenticating(user: state.user);
    try {
      await ref.read(authRepositoryProvider).resetPassword(email: email);
      state = AuthViewState.unauthenticated();
      return AuthActionResult.success();
    } catch (error) {
      final message = ExceptionMapper.map(error).message;
      state = AuthViewState.error(message: message, user: state.user);
      return AuthActionResult.failure(message);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(favoritesControllerProvider.notifier).clearMemory();
    state = AuthViewState.unauthenticated();
  }

  void clearError() {
    if (state.message == null) {
      return;
    }
    state = state.copyWith(clearMessage: true);
  }

  void _handleAuthChange(AuthState authState) {
    final session = authState.session;
    if (session?.user != null) {
      state = AuthViewState.authenticated(session!.user);
      return;
    }
    state = AuthViewState.unauthenticated();
  }
}
