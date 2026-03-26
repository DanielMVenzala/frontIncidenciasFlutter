import 'comment_model.dart';

/// Modelo que representa una incidencia.
/// Mapea los campos del backend (en español) a propiedades en inglés.
/// Las coordenadas (latitud/longitud) se obtienen por geocodificación
/// automática de la dirección al crear la incidencia en el backend.
class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String address;
  final String priority;
  final String status;
  final List<String> imageUrls;
  final String userId;
  final double? latitud;
  final double? longitud;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<CommentModel> comments;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.priority,
    required this.status,
    required this.imageUrls,
    required this.userId,
    required this.createdAt,
    this.latitud,
    this.longitud,
    this.updatedAt,
    this.comments = const [],
  });

  // Helpers para comprobar el estado sin comparar strings manualmente
  bool get hasCoordinates => latitud != null && longitud != null;
  bool get isClosed => status == 'resuelto';
  bool get isRejected => status == 'rechazada';
  bool get isInProgress => status == 'en progreso';

  /// Convierte el JSON del backend a IncidentModel.
  /// Los nombres de campo del backend están en español (titulo, descripcion, etc.)
  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] ?? '',
      title: json['titulo'] ?? '',
      description: json['descripcion'] ?? '',
      address: json['direccion'] ?? '',
      priority: json['prioridad'] ?? 'media',
      status: json['estado'] ?? 'pendiente',
      imageUrls: List<String>.from(json['imagenes'] ?? []),
      userId: json['usuario'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
        json['creadoEn'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['actualizadoEn'] != null
          ? DateTime.parse(json['actualizadoEn'])
          : null,
      comments:
          (json['comentarios'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': title,
      'descripcion': description,
      'direccion': address,
      'prioridad': priority,
      'estado': status,
    };
  }
}
