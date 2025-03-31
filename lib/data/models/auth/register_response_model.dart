class RegisterResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? miembro;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.miembro,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'],
      message: json['message'],
      miembro: json['miembro'],
    );
  }
}