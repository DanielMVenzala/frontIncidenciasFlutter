import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/incident_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _editing = false;
  bool _changingPassword = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _uploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Muestra opciones para gestionar la foto de perfil:
  /// - Hacer una foto con la cámara
  /// - Elegir una foto de la galería
  /// - Eliminar la foto actual (solo si el usuario tiene una)
  Future<void> _changeProfilePhoto() async {
    final user = context.read<AuthProvider>().user;
    final hasPhoto = user?.hasProfilePhoto == true;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Hacer una foto'),
                onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la galería'),
                onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
              ),
              // Solo permitir eliminar si hay foto actualmente
              if (hasPhoto)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.statusRejected),
                  title: Text(
                    'Eliminar foto actual',
                    style: TextStyle(color: AppColors.statusRejected),
                  ),
                  onTap: () => Navigator.pop(ctx, _PhotoAction.delete),
                ),
            ],
          ),
        ),
      ),
    );

    if (action == null || !mounted) return;

    if (action == _PhotoAction.delete) {
      await _deleteProfilePhoto();
      return;
    }

    final source = action == _PhotoAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      // Capturar servicios antes del await para evitar uso de context tras async gap
      final incidentService = context.read<IncidentService>();
      final authProvider = context.read<AuthProvider>();

      // Reutilizar el endpoint de subida de imágenes a Cloudinary
      final url = await incidentService.uploadImage(pickedFile.path);

      // Actualizar el perfil con la URL de la foto
      await authProvider.updateProfile({'fotoPerfil': url});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la foto')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  /// Pide confirmación y elimina la foto de perfil del usuario.
  /// Al ponerla a null, la app vuelve a mostrar la inicial del nombre.
  Future<void> _deleteProfilePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Quieres eliminar tu foto de perfil? Volverás a tener la inicial de tu nombre como avatar.'),
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

    if (confirmed != true || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final authProvider = context.read<AuthProvider>();
      // Enviar fotoPerfil: null para que el backend la borre
      await authProvider.updateProfile({'fotoPerfil': null});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil eliminada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la foto')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final data = <String, dynamic>{
      'nombre': _nameController.text.trim(),
    };

    if (_changingPassword && _newPasswordController.text.isNotEmpty) {
      data['clave'] = _newPasswordController.text;
    }

    await authProvider.updateProfile(data);

    if (authProvider.error == null && mounted) {
      setState(() {
        _editing = false;
        _changingPassword = false;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Avatar grande — pulsar para cambiar foto
              GestureDetector(
                onTap: _changeProfilePhoto,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user?.hasProfilePhoto == true
                            ? NetworkImage(user!.profilePhoto!)
                            : null,
                        child: _uploadingPhoto
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : user?.hasProfilePhoto != true
                                ? Text(
                                    (user?.name.isNotEmpty == true)
                                        ? user!.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Nombre
              Text(
                user?.name ?? 'Usuario',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // Rol badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.isAdmin == true
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.isAdmin == true ? 'Administrador' : 'Usuario',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user?.isAdmin == true
                        ? AppColors.accent
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (authProvider.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusRejected.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: AppColors.statusRejected),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Formulario
              TextFormField(
                controller: _nameController,
                enabled: _editing,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              // Cambiar contraseña
              if (_editing) ...[
                const SizedBox(height: 16),
                if (!_changingPassword)
                  TextButton.icon(
                    onPressed: () => setState(() => _changingPassword = true),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Cambiar contraseña'),
                  )
                else ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                    ),
                    validator: (value) {
                      if (_changingPassword && (value == null || value.isEmpty)) {
                        return 'Introduce tu contraseña actual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (value) {
                      if (_changingPassword && (value == null || value.isEmpty)) {
                        return 'Introduce la nueva contraseña';
                      }
                      if (_changingPassword && value != null && value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (_changingPassword && value != _newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 28),

              const SizedBox(height: 28),

              if (_editing) ...[
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _save,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    _nameController.text = user?.name ?? '';
                    _emailController.text = user?.email ?? '';
                    setState(() => _editing = false);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Acciones disponibles en el menú de foto de perfil.
enum _PhotoAction { camera, gallery, delete }
