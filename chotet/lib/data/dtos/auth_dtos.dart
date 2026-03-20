class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserInfo? user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class UserInfo {
  final Long? id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? avatarUrl;
  final String? phoneNumber;
  final Set<String>? roles;

  UserInfo({
    this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.nickname,
    this.avatarUrl,
    this.phoneNumber,
    this.roles,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      roles: json['roles'] != null ? Set<String>.from(json['roles']) : null,
    );
  }
}

// Simple wrapper for Long since Dart uses int
typedef Long = int;
