import 'api_service.dart';

/// Servicio de autocompletado de direcciones.
/// Las peticiones se enrutan a través del backend para no exponer
/// la API Key de Google Maps en el frontend.
class PlacesService {
  final ApiService _api;

  PlacesService(this._api);

  /// Busca sugerencias de direcciones a partir de un texto parcial.
  Future<List<PlaceSuggestion>> getSuggestions(String input) async {
    if (input.length < 3) return [];

    try {
      final response = await _api.dio.get(
        '/incidents/places/autocomplete',
        queryParameters: {'input': input},
      );

      final List data = response.data;
      return data
          .map((p) => PlaceSuggestion(
                description: p['description'] ?? '',
                placeId: p['placeId'] ?? '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({required this.description, required this.placeId});
}
