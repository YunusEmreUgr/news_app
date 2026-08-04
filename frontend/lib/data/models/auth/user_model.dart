import '../../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool status;
  final List<String> claims;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.status = true,
    this.claims = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status'] is bool ? json['status'] : true,
      claims: json['claims'] is List
          ? (json['claims'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'status': status,
        'claims': claims,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        status: status,
        claims: claims,
      );
}
