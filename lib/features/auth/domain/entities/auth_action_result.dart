class AuthActionResult {
  const AuthActionResult._({
    required this.success,
    required this.requiresVerification,
    this.message,
  });

  final bool success;
  final bool requiresVerification;
  final String? message;

  factory AuthActionResult.success() {
    return const AuthActionResult._(
      success: true,
      requiresVerification: false,
    );
  }

  factory AuthActionResult.requiresVerification({String? message}) {
    return AuthActionResult._(
      success: true,
      requiresVerification: true,
      message: message,
    );
  }

  factory AuthActionResult.failure(String message) {
    return AuthActionResult._(
      success: false,
      requiresVerification: false,
      message: message,
    );
  }
}
