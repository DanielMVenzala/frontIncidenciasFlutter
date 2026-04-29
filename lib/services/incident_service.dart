import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/incident_model.dart';
import 'api_service.dart';

class IncidentService {
  final ApiService _api;

  IncidentService(this._api);

  /// Obtener lista de incidencias con filtros opcionales
  Future<List<IncidentModel>> getIncidents({
    Map<String, dynamic>? filters,
  }) async {
    final response = await _api.dio.get(
      '/incidents',
      queryParameters: filters,
    );
    final List data = response.data;
    return data.map((json) => IncidentModel.fromJson(json)).toList();
  }

  /// Obtener incidencia por ID
  Future<IncidentModel> getIncidentById(String id) async {
    final response = await _api.dio.get('/incidents/$id');
    return IncidentModel.fromJson(response.data);
  }

  /// Crear incidencia
  Future<IncidentModel> createIncident({
    required String title,
    required String description,
    required String address,
    required String userId,
    required String priority,
    List<String> imageUrls = const [],
  }) async {
    final Map<String, dynamic> data = {
      'titulo': title,
      'descripcion': description,
      'direccion': address,
      'usuario': userId,
      'prioridad': priority,
      'imagenes': imageUrls,
    };
    final response = await _api.dio.post('/incidents', data: data);
    return IncidentModel.fromJson(response.data);
  }

  /// Actualizar incidencia (prioridad, estado, etc.)
  Future<IncidentModel> updateIncident(String id, Map<String, dynamic> data) async {
    final response = await _api.dio.patch('/incidents/$id', data: data);
    return IncidentModel.fromJson(response.data);
  }

  /// Borrar incidencia
  Future<void> deleteIncident(String id) async {
    await _api.dio.delete('/incidents/$id');
  }

  /// Añadir comentario a una incidencia
  Future<Map<String, dynamic>> addComment(String incidentId, String texto, String userEmail) async {
    final response = await _api.dio.post(
      '/incidents/$incidentId/comments',
      data: {'texto': texto, 'usuario': userEmail},
    );
    return response.data;
  }

  /// Descarga el informe Excel de incidencias y lo guarda en el almacenamiento del dispositivo.
  /// Devuelve la ruta local del archivo descargado.
  /// Acepta filtros opcionales (fechas, estado, prioridad).
  Future<String> downloadIncidentsReport({
    Map<String, dynamic>? filters,
  }) async {
    final response = await _api.dio.get<List<int>>(
      '/incidents/report/excel',
      queryParameters: filters,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    // Guardar en el directorio temporal del dispositivo
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/informe_incidencias_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(response.data!);

    return filePath;
  }

  /// Subir imagen de incidencia
  Future<String> uploadImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _api.dio.post(
      '/files/incident',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['url'] ?? response.data['secureUrl'] ?? '';
  }
}
