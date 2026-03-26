import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';

class PhonesPage extends StatelessWidget {
  const PhonesPage({super.key});

  static const _phones = [
    _PhoneEntry(
      name: 'Ayuntamiento — Centralita',
      phone: '953 210 000',
      icon: Icons.account_balance,
    ),
    _PhoneEntry(
      name: 'Atención Ciudadana',
      phone: '953 553 309',
      icon: Icons.headset_mic,
    ),
    _PhoneEntry(
      name: 'Bomberos',
      phone: '953 210 080',
      icon: Icons.local_fire_department,
    ),
    _PhoneEntry(
      name: 'Biblioteca Municipal',
      phone: '953 210 010',
      icon: Icons.menu_book,
    ),
  ];

  Future<void> _call(BuildContext context, String phone) async {
    final cleaned = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede abrir el marcador')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teléfonos de interés')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _phones.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = _phones[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(entry.icon, color: AppColors.primary),
              ),
              title: Text(
                entry.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                entry.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                color: AppColors.statusResolved,
                tooltip: 'Llamar',
                onPressed: () => _call(context, entry.phone),
              ),
              onTap: () => _call(context, entry.phone),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneEntry {
  final String name;
  final String phone;
  final IconData icon;

  const _PhoneEntry({
    required this.name,
    required this.phone,
    required this.icon,
  });
}
