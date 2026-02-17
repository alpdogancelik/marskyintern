import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../domain/auth_state.dart' as domain;

abstract class AuthRepository {
  Stream<domain.AuthState> authStateChanges();
  domain.AuthState get currentAuthState;

  // Legacy accessors used by presentation/controllers.
  Session? get currentSession;
  User? get currentUser;
  String? get currentUserId;

  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });

  Future<void> resetPassword({
    required String email,
  });

  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  });

  Future<void> resendSignupOtp({
    required String email,
  });

  Future<void> signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<domain.AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange
        .map((event) => _mapToAuthState(event.session))
        .distinct();
  }

  @override
  domain.AuthState get currentAuthState {
    return _mapToAuthState(_client.auth.currentSession);
  }

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) {
    return _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  @override
  Future<void> resendSignupOtp({
    required String email,
  }) async {
    await _client.auth.resend(
      email: email,
      type: OtpType.signup,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  domain.AuthState _mapToAuthState(Session? session) {
    final userId = session?.user.id ?? _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const domain.AuthState.unauthenticated();
    }
    return domain.AuthState.authenticated(userId);
  }
}
