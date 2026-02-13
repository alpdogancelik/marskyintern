import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';

abstract class AuthRepository {
  Stream<AuthState> get sessionStream;
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
  Stream<AuthState> get sessionStream => _client.auth.onAuthStateChange;

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
  Future<void> signOut() => _client.auth.signOut();
}
