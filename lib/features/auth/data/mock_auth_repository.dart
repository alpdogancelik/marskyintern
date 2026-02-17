import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_state.dart' as domain;
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.autoAuthenticate = true,
    this.defaultUserId = 'mock-user',
    this.defaultEmail = 'mock.user@marsky.io',
  }) : _controller = StreamController<domain.AuthState>.broadcast() {
    if (autoAuthenticate) {
      _setAuthenticated(
        userId: defaultUserId,
        email: defaultEmail,
        emitEvent: false,
      );
    }
    _emitCurrentState();
  }

  final bool autoAuthenticate;
  final String defaultUserId;
  final String defaultEmail;
  final StreamController<domain.AuthState> _controller;
  Session? _session;
  User? _user;

  @override
  Stream<domain.AuthState> authStateChanges() => _controller.stream;

  @override
  domain.AuthState get currentAuthState {
    final userId = _user?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const domain.AuthState.unauthenticated();
    }
    return domain.AuthState.authenticated(userId);
  }

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _user;

  @override
  String? get currentUserId => _user?.id;

  @override
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final resolvedEmail = email.trim().isEmpty ? defaultEmail : email.trim();
    _setAuthenticated(
      userId: defaultUserId,
      email: resolvedEmail,
    );
    return AuthResponse(
      session: _session,
      user: _user,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final resolvedEmail = email.trim().isEmpty ? defaultEmail : email.trim();
    _setAuthenticated(
      userId: defaultUserId,
      email: resolvedEmail,
      metadata: data,
    );
    return AuthResponse(
      session: _session,
      user: _user,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {}

  @override
  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw const AuthException('Verification code is required.');
    }
    final resolvedEmail = email.trim().isEmpty ? defaultEmail : email.trim();
    _setAuthenticated(
      userId: defaultUserId,
      email: resolvedEmail,
    );
    return AuthResponse(
      session: _session,
      user: _user,
    );
  }

  @override
  Future<void> resendSignupOtp({
    required String email,
  }) async {}

  @override
  Future<void> signOut() async {
    _session = null;
    _user = null;
    _emitCurrentState();
  }

  void dispose() {
    _controller.close();
  }

  void _setAuthenticated({
    required String userId,
    required String email,
    Map<String, dynamic>? metadata,
    bool emitEvent = true,
  }) {
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(const Duration(days: 7));

    _session = Session.fromJson(
      <String, dynamic>{
        'access_token': 'mock-access-token',
        'refresh_token': 'mock-refresh-token',
        'token_type': 'bearer',
        'expires_in': const Duration(days: 7).inSeconds,
        'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'user': <String, dynamic>{
          'id': userId,
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': email,
          'app_metadata': <String, dynamic>{
            'provider': 'email',
            'providers': <String>['email'],
          },
          'user_metadata': <String, dynamic>{
            'full_name': 'Mock User',
            ...?metadata,
          },
          'created_at': now.toIso8601String(),
        },
      },
    );
    _user = _session?.user;

    if (emitEvent) {
      _emitCurrentState();
    }
  }

  void _emitCurrentState() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(currentAuthState);
  }
}
