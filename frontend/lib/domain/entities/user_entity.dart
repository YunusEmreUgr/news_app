class UserEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool status;
  final List<String> claims;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.status = true,
    this.claims = const [],
  });

  String get fullName => '$firstName $lastName';
  bool hasClaim(String claim) => claims.contains(claim);
}
