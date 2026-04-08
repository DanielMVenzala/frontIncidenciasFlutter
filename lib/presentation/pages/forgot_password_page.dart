import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';

/// Pantalla para solicitar el restablecimiento de contraseña.
/// El usuario introduce su email y recibe un enlace por correo.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _emailSent
                  ? _buildConfirmationMessage()
                  : _buildForm(authProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_reset, size: 64, color: Colors.white),
        const SizedBox(height: 12),
        const Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Introduce tu email para recibir el enlace',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authProvider.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(color: AppColors.statusRejected, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Introduce tu email';
                    if (!value.contains('@')) return 'Email no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Enviar enlace'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.mark_email_read, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            '¡Revisa tu correo!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Si el email está registrado, recibirás un enlace para restablecer tu contraseña. Revisa también la carpeta de spam.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Volver al inicio de sesión'),
          ),
        ],
      ),
    );
  }
}
