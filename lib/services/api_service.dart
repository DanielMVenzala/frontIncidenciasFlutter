import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        contentType: 'application/json',
      ),
    );

    // Interceptor que añade el JWT a cada petición
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // Guardar token tras login/registro
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Borrar token al cerrar sesión
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }

  // Leer token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Guardar userId para restaurar sesión
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  // Leer userId guardado
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  // Borrar userId al cerrar sesión
  Future<void> deleteUserId() async {
    await _storage.delete(key: 'user_id');
  }
}
