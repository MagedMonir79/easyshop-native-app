class UserModel {
  final int id;
  final String name;
  final String email;
  final List<dynamic> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  /// 🔥 Helper لتحويل أي نوع لـ int بأمان
  static int _safeParseId(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  /// 🔥 Helper لتحويل أي قيمة String بأمان
  static String _safeString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _safeParseId(json['id']),
      name: _safeString(json['name']),
      email: _safeString(json['email']),
      roles: json['roles'] ?? [],
    );
  }
}