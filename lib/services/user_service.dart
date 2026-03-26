import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  /// Obtener todos los usuarios (solo admin)
  Future<List<UserModel>> getAllUsers() async {
    final response = await _api.dio.get('/users');
    final List data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  /// Actualizar usuario (admin)
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final response = await _api.dio.patch('/users/$id', data: data);
    return UserModel.fromJson(response.data);
  }

  /// Bloquear/desbloquear usuario (admin)
  Future<Map<String, dynamic>> toggleBlock(String id) async {
    final response = await _api.dio.patch('/users/$id/toggle-block');
    return Map<String, dynamic>.from(response.data);
  }

  /// Borrar usuario (admin)
  Future<void> deleteUser(String id) async {
    await _api.dio.delete('/users/$id');
  }
}
