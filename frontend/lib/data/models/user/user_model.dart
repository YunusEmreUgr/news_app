import '../../../domain/entities/user_entity.dart';

class UserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final bool emailConfirmed;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailConfirmed,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] is int
          ? json['userId']
          : (int.tryParse(json['userId']?.toString() ?? '0') ?? 0),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailConfirmed: json['emailConfirmed'] == true || json['emailConfirmed']?.toString() == 'true',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'emailConfirmed': emailConfirmed,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserEntity toEntity() => UserEntity(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        status: emailConfirmed,
      );
}
