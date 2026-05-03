class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
        expiresAt: (json['expires_at'] as num?)?.toInt() ?? 0,
      );

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresAt;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_at': expiresAt,
      };
}
