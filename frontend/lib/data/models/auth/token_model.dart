import '../../../domain/entities/token_entity.dart';

class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String? expiration;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiration,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    String access = '';
    String refresh = '';

    if (json.containsKey('accessToken')) {
      final acc = json['accessToken'];
      if (acc is Map) {
        access = acc['token']?.toString() ?? acc['accessToken']?.toString() ?? '';
      } else {
        access = acc.toString();
      }
    } else if (json.containsKey('token')) {
      access = json['token'].toString();
    }

    if (json.containsKey('refreshToken')) {
      refresh = json['refreshToken'].toString();
    }

    return TokenModel(
      accessToken: access,
      refreshToken: refresh,
      expiration: json['expiration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiration': expiration,
      };

  TokenEntity toEntity() => TokenEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiration: expiration,
      );
}
