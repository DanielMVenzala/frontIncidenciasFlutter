import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => IconButton(
            icon: Icon(themeProvider.isDark
                ? Icons.light_mode
                : Icons.dark_mode),
            tooltip: themeProvider.isDark ? 'Modo claro' : 'Modo oscuro',
            onPressed: () => themeProvider.toggle(),
          ),
        ),
        title: const Text('Incidencias Martos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        (user?.name.isNotEmpty == true)
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${user?.name ?? 'Usuario'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user?.isAdmin == true
                                  ? 'Administrador'
                                  : 'Usuario',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Título sección
              Text(
                'Menú principal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Opciones del menú
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    if (!authProvider.isAdmin)
                      _MenuCard(
                        icon: Icons.add_circle_outline,
                        title: 'Abrir incidencia',
                        color: AppColors.statusResolved,
                        onTap: () => context.push(AppRoutes.createIncident),
                      ),

                    _MenuCard(
                      icon: Icons.list_alt,
                      title: authProvider.isAdmin
                          ? 'Todas las incidencias'
                          : 'Mis incidencias',
                      color: AppColors.primary,
                      onTap: () => context.push(
                        authProvider.isAdmin
                            ? AppRoutes.allIncidents
                            : AppRoutes.myIncidents,
                      ),
                    ),

                    _MenuCard(
                      icon: Icons.person_outline,
                      title: 'Mi perfil',
                      color: AppColors.accent,
                      onTap: () => context.push(AppRoutes.profile),
                    ),

                    if (authProvider.isAdmin) ...[
                      _MenuCard(
                        icon: Icons.map_outlined,
                        title: 'Mapa de incidencias',
                        color: AppColors.statusInProgress,
                        onTap: () => context.push(AppRoutes.incidentsMap),
                      ),

                      _MenuCard(
                        icon: Icons.people_outline,
                        title: 'Gestionar usuarios',
                        color: AppColors.primaryLight,
                        onTap: () => context.push(AppRoutes.adminUsers),
                      ),

                      _MenuCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'Estadísticas',
                        color: AppColors.accent,
                        onTap: () => context.push(AppRoutes.statistics),
                      ),
                    ],

                    _MenuCard(
                      icon: Icons.phone_in_talk,
                      title: 'Teléfonos de interés',
                      color: AppColors.primaryDark,
                      onTap: () => context.push(AppRoutes.phones),
                    ),

                    _MenuCard(
                      icon: Icons.logout,
                      title: 'Cerrar sesión',
                      color: AppColors.statusRejected,
                      onTap: () async {
                        await authProvider.logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
