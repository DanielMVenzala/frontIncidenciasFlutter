import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/user_service.dart';

/// Punto de entrada de la aplicación Flutter.
/// Inicializa los servicios y los inyecta mediante MultiProvider
/// para que estén disponibles en todo el árbol de widgets.
void main() {
  // Crear servicios (capa de red)
  final apiService = ApiService();
  final authService = AuthService(apiService);
  final incidentService = IncidentService(apiService);
  final userService = UserService(apiService);
  final themeProvider = ThemeProvider(const FlutterSecureStorage());

  runApp(
    // MultiProvider inyecta servicios y providers en el árbol de widgets.
    // Los ChangeNotifierProvider notifican a la UI cuando cambia el estado.
    // Los Provider.value exponen servicios sin gestión de estado reactiva.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => IncidentProvider(incidentService),
        ),
        ChangeNotifierProvider.value(value: themeProvider),
        Provider.value(value: incidentService),
        Provider.value(value: userService),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _initialized = false;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Ejecutar tras el primer frame para tener acceso al context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
    });
  }

  /// Restaura el tema y la sesión del usuario al abrir la app.
  /// Si hay un token JWT guardado en SecureStorage, intenta revalidarlo.
  /// Una vez listo, crea el router con las rutas protegidas.
  Future<void> _restoreSession() async {
    final themeProvider = context.read<ThemeProvider>();
    final authProvider = context.read<AuthProvider>();
    await themeProvider.init();
    await authProvider.restoreSession();
    if (mounted) {
      _router = createRouter(authProvider);
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Mientras restaura sesión, mostrar pantalla de carga
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeProvider.themeMode,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'Incidencias Martos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}
