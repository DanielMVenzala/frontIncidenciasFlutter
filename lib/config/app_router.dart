import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/pages/forgot_password_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/create_incident_page.dart';
import '../presentation/pages/incidents_list_page.dart';
import '../presentation/pages/incident_detail_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/admin_users_page.dart';
import '../presentation/pages/incidents_map_page.dart';
import '../presentation/pages/statistics_page.dart';
import '../presentation/pages/phones_page.dart';
import 'app_routes.dart';

/// Crea el router de la app con protección de rutas.
/// El redirect actúa como guard global: redirige a login si no hay sesión
/// y al dashboard si el usuario ya está logueado e intenta acceder a login/register.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      // Si no está logueado y no está en auth, redirigir a login
      if (!loggedIn && !isAuthRoute) return AppRoutes.login;

      // Si está logueado y está en auth, redirigir a dashboard
      if (loggedIn && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.createIncident,
        builder: (context, state) => const CreateIncidentPage(),
      ),
      GoRoute(
        path: AppRoutes.myIncidents,
        builder: (context, state) =>
            const IncidentsListPage(title: 'Mis Incidencias'),
      ),
      GoRoute(
        path: AppRoutes.allIncidents,
        builder: (context, state) =>
            const IncidentsListPage(title: 'Todas las Incidencias'),
      ),
      GoRoute(
        path: AppRoutes.incidentDetail,
        builder: (context, state) => IncidentDetailPage(
          incidentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        path: AppRoutes.incidentsMap,
        builder: (context, state) => const IncidentsMapPage(),
      ),
      GoRoute(
        path: AppRoutes.statistics,
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: AppRoutes.phones,
        builder: (context, state) => const PhonesPage(),
      ),
    ],
  );
}
