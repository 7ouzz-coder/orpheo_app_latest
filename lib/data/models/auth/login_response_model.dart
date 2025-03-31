class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final UserModel user;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final int id;
  final String username;
  final String? email;
  final String role;
  final String grado;
  final String? cargo;
  final String? memberFullName;
  final int? miembroId;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    required this.grado,
    this.cargo,
    this.memberFullName,
    this.miembroId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      grado: json['grado'],
      cargo: json['cargo'],
      memberFullName: json['memberFullName'],
      miembroId: json['miembroId'],
    );
  }
}