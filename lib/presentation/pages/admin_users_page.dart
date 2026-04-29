import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userService = context.read<UserService>();
      _users = await userService.getAllUsers();
    } catch (e) {
      _error = 'Error al cargar usuarios';
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleBlock(UserModel user) async {
    final action = user.bloqueado ? 'desbloquear' : 'bloquear';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${user.bloqueado ? "Desbloquear" : "Bloquear"} usuario'),
        content: Text('¿Seguro que quieres $action a ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: user.bloqueado ? AppColors.statusResolved : AppColors.statusPending,
            ),
            child: Text(user.bloqueado ? 'Desbloquear' : 'Bloquear'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final userService = context.read<UserService>();
      final result = await userService.toggleBlock(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['mensaje'] ?? 'Hecho')),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar estado del usuario')),
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusRejected),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final userService = context.read<UserService>();
      await userService.deleteUser(user.id);
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar usuario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: AppColors.textLight),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _UserCard(
                        user: user,
                        onDelete: () => _deleteUser(user),
                        onToggleBlock: () => _toggleBlock(user),
                      );
                    },
                  ),
                ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;
  final VoidCallback onToggleBlock;

  const _UserCard({
    required this.user,
    required this.onDelete,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';

    return Opacity(
      opacity: user.bloqueado ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar (muestra foto de perfil si existe)
              CircleAvatar(
                radius: 24,
                backgroundColor: user.bloqueado
                    ? Colors.grey.withValues(alpha: 0.15)
                    : isAdmin
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: user.hasProfilePhoto && !user.bloqueado
                    ? NetworkImage(user.profilePhoto!)
                    : null,
                child: user.bloqueado
                    ? const Icon(Icons.block, color: Colors.grey)
                    : !user.hasProfilePhoto
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? AppColors.accent : AppColors.primary,
                            ),
                          )
                        : null,
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppColors.accent.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAdmin ? 'Admin' : 'Usuario',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isAdmin ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                        ),
                        if (user.bloqueado) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.statusRejected.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Bloqueado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusRejected,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Bloquear/Desbloquear
              IconButton(
                icon: Icon(user.bloqueado ? Icons.lock_open : Icons.block),
                color: user.bloqueado ? AppColors.statusResolved : AppColors.statusPending,
                tooltip: user.bloqueado ? 'Desbloquear' : 'Bloquear',
                onPressed: onToggleBlock,
              ),
              // Eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.statusRejected,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
