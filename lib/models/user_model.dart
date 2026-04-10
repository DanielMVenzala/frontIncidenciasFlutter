/// Modelo de usuario. Mapea el JSON del backend.
/// El campo 'bloqueado' indica si un admin ha bloqueado al usuario.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool bloqueado;
  final String? profilePhoto;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bloqueado = false,
    this.profilePhoto,
  });

  bool get isAdmin => role == 'admin';
  bool get hasProfilePhoto => profilePhoto != null && profilePhoto!.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['nombre'] ?? '',
      email: json['email'] ?? '',
      role: json['rol'] ?? 'usuario',
      bloqueado: json['bloqueado'] ?? false,
      profilePhoto: json['fotoPerfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': name, 'email': email};
  }
}
