class TokenEntity {
  final String accessToken;
  final String refreshToken;
  final String? expiration;

  const TokenEntity({
    required this.accessToken,
    required this.refreshToken,
    this.expiration,
  });
}
