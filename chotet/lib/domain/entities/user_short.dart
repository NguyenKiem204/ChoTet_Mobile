class UserShort {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? imageUrl;
  final String? nickname;

  const UserShort({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.imageUrl,
    this.nickname,
  });

  factory UserShort.fromJson(Map<String, dynamic> json) {
    return UserShort(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'],
      imageUrl: json['imageUrl'],
      nickname: json['nickname'],
    );
  }

  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }
}
