import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _incidentService;

  List<IncidentModel> _incidents = [];
  bool _isLoading = false;
  String? _error;

  IncidentProvider(this._incidentService);

  List<IncidentModel> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todas las incidencias (para admin) con filtros opcionales
  Future<void> loadAllIncidents({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incidents = await _incidentService.getIncidents(filters: filters);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga solo las incidencias del usuario
  Future<void> loadMyIncidents(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final all = await _incidentService.getIncidents();
      _incidents = all.where((i) => i.userId == userId).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene una incidencia por ID: siempre desde la API para datos frescos
  Future<IncidentModel?> getIncidentById(String id) async {
    try {
      final incident = await _incidentService.getIncidentById(id);
      // Actualizar caché local si existe
      final index = _incidents.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incidents[index] = incident;
      }
      return incident;
    } catch (_) {
      // Fallback a caché si la API falla
      try {
        return _incidents.firstWhere((i) => i.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> createIncident({
    required String title,
    required String description,
    required String address,
    required String userId,
    required String priority,
    List<String> imagePaths = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Subir todas las imágenes en paralelo
      List<String> imageUrls = [];
      if (imagePaths.isNotEmpty) {
        imageUrls = await Future.wait(
          imagePaths.map((path) => _incidentService.uploadImage(path)),
        );
      }

      final incident = await _incidentService.createIncident(
        title: title,
        description: description,
        address: address,
        userId: userId,
        priority: priority,
        imageUrls: imageUrls,
      );
      _incidents.insert(0, incident);
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

  Future<bool> updateIncident(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _incidentService.updateIncident(id, data);
      final index = _incidents.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incidents[index] = updated;
      }
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

  Future<bool> deleteIncident(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _incidentService.deleteIncident(id);
      _incidents.removeWhere((i) => i.id == id);
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
