import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  /// Login: guarda token y obtiene perfil completo
  Future<UserModel> login(String email, String password) async {
    final response = await _api.dio.post('/users/login', data: {
      'email': email,
      'clave': password,
    });
    final data = response.data;

    // Guardar token y userId para restaurar sesión
    await _api.saveToken(data['token']);
    await _api.saveUserId(data['id']);

    // La respuesta del login solo trae id, email, token
    // Hacemos GET /users/:id para obtener el perfil completo (name, role, etc.)
    return await getProfile(data['id']);
  }

  /// Registro: solo crea la cuenta, no inicia sesión (requiere activación por email)
  Future<String> register(String name, String email, String password) async {
    final response = await _api.dio.post('/users/register', data: {
      'nombre': name,
      'email': email,
      'clave': password,
    });
    final data = response.data;
    return data['mensaje'] ?? 'Revisa tu correo para activar tu cuenta';
  }

  /// Obtener perfil del usuario actual
  Future<UserModel> getProfile(String userId) async {
    final response = await _api.dio.get('/users/$userId');
    return UserModel.fromJson(response.data);
  }

  /// Actualizar perfil
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _api.dio.patch('/users/$userId', data: data);
    return UserModel.fromJson(response.data);
  }

  /// Intentar restaurar sesión con token y userId guardados
  Future<UserModel?> restoreSession() async {
    final token = await _api.getToken();
    final userId = await _api.getUserId();
    if (token == null || userId == null) return null;

    try {
      return await getProfile(userId);
    } catch (_) {
      // Token expirado o inválido, limpiar datos
      await logout();
      return null;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _api.deleteToken();
    await _api.deleteUserId();
  }
}
