import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Intenta restaurar la sesión guardada al abrir la app
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.restoreSession();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _successMessage = await _authService.register(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Solicita un email para restablecer la contraseña.
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      _successMessage = await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.updateProfile(_user!.id, data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'El servidor tarda en responder. Inténtalo de nuevo.';
        case DioExceptionType.connectionError:
          return 'Sin conexión a internet.';
        default:
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            final msg = data['message'];
            return msg is List ? msg.first.toString() : msg.toString();
          }
          return 'Error del servidor (${e.response?.statusCode ?? 'desconocido'}).';
      }
    }
    return 'Error inesperado. Inténtalo de nuevo.';
  }
}
