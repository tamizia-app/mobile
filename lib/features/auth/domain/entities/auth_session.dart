class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;

  bool isExpiringSoon({
    DateTime? now,
    Duration threshold = const Duration(seconds: 60),
  }) {
    return (now ?? DateTime.now()).isAfter(expiresAt.subtract(threshold));
  }
}
