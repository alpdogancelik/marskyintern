import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_status.dart';

class AuthViewState {
  const AuthViewState({
    required this.status,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final User? user;
  final String? message;

  bool get isLoading => status == AuthStatus.authenticating;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  factory AuthViewState.unauthenticated({String? message}) {
    return AuthViewState(
      status: AuthStatus.unauthenticated,
      message: message,
    );
  }

  factory AuthViewState.authenticating({User? user}) {
    return AuthViewState(
      status: AuthStatus.authenticating,
      user: user,
    );
  }

  factory AuthViewState.authenticated(User? user) {
    return AuthViewState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  factory AuthViewState.error({
    required String message,
    User? user,
  }) {
    return AuthViewState(
      status: AuthStatus.error,
      user: user,
      message: message,
    );
  }

  AuthViewState copyWith({
    AuthStatus? status,
    User? user,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthViewState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
