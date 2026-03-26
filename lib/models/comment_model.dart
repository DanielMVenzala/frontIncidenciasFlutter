/// Modelo de comentario/nota de una incidencia.
/// El backend devuelve el autor como un objeto {id, nombre},
/// que se extrae en fromJson para mostrar quién escribió la nota.
class CommentModel {
  final int id;
  final String texto;
  final DateTime creadoEn;
  final String? autorId;
  final String? autorNombre;

  CommentModel({
    required this.id,
    required this.texto,
    required this.creadoEn,
    this.autorId,
    this.autorNombre,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final autor = json['autor'];
    return CommentModel(
      id: json['id'] ?? 0,
      texto: json['texto'] ?? '',
      creadoEn: DateTime.parse(
          json['creadoEn'] ?? DateTime.now().toIso8601String()),
      autorId: autor is Map ? autor['id'] : null,
      autorNombre: autor is Map ? autor['nombre'] : null,
    );
  }
}
