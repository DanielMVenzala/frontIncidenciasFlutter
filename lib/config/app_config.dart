/// Configuración centralizada de conexión al backend.
/// Todas las llamadas HTTP del frontend parten de baseUrl.
/// Para desarrollo local, cambiar a 'http://10.0.2.2:3000/api/v1' (emulador)
/// o 'http://TU_IP_LOCAL:3000/api/v1' (dispositivo real).
class AppConfig {
  static const String baseUrl = 'https://backendincidenciasnest.onrender.com/api/v1';
  static const int connectTimeout = 60000; // 60s — Render puede tardar en despertar
  static const int receiveTimeout = 60000;
}
