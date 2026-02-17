class AuthState {
  const AuthState._({
    required this.userId,
    required this.isAuthenticated,
  });

  const AuthState.unauthenticated()
      : this._(
          userId: null,
          isAuthenticated: false,
        );

  const AuthState.authenticated(String userId)
      : this._(
          userId: userId,
          isAuthenticated: true,
        );

  final String? userId;
  final bool isAuthenticated;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.userId == userId &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode => Object.hash(userId, isAuthenticated);
}
