import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/incident_model.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/incident_service.dart';

class IncidentDetailPage extends StatefulWidget {
  final String incidentId;

  const IncidentDetailPage({super.key, required this.incidentId});

  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<IncidentDetailPage> {
  IncidentModel? _incident;
  bool _loading = true;
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  int _currentPage = 0;
  bool _sendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadIncident();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final service = context.read<IncidentService>();

    setState(() => _sendingComment = true);
    try {
      await service.addComment(widget.incidentId, text, auth.user!.email);
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
      await _loadIncident();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota añadida correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el comentario: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Future<void> _loadIncident() async {
    final provider = context.read<IncidentProvider>();
    _incident = await provider.getIncidentById(widget.incidentId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de incidencia'),
        actions: [
          if (isAdmin && _incident != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAdminAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'status',
                  child: Text('Cambiar estado'),
                ),
                const PopupMenuItem(
                  value: 'priority',
                  child: Text('Cambiar prioridad'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _incident == null
          ? const Center(child: Text('Incidencia no encontrada'))
          : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final incident = _incident!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imágenes (carrusel con flechas e indicadores)
          if (incident.imageUrls.isNotEmpty)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: incident.imageUrls.length,
                    itemBuilder: (context, index) {
                      final image = Image.network(
                        incident.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );

                      final child = index == 0
                          ? Hero(
                              tag: 'incident_image_${incident.id}',
                              child: image,
                            )
                          : image;

                      return GestureDetector(
                        onTap: () => _openFullscreenGallery(
                          context,
                          incident.imageUrls,
                          index,
                        ),
                        child: child,
                      );
                    },
                  ),
                  if (incident.imageUrls.length > 1) ...[
                    // Flecha izquierda
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _ArrowButton(
                          icon: Icons.chevron_left,
                          onTap: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    ),
                    // Flecha derecha
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _ArrowButton(
                          icon: Icons.chevron_right,
                          onTap: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ),
                    ),
                    // Indicador de puntos
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          incident.imageUrls.length,
                          (i) => Container(
                            width: _currentPage == i ? 10 : 7,
                            height: _currentPage == i ? 10 : 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Contador
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentPage + 1}/${incident.imageUrls.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  incident.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Chips de estado y prioridad
                Row(
                  children: [
                    _StatusChip(
                      label: _statusLabel(incident.status),
                      color: _statusColor(incident.status),
                      icon: _statusIcon(incident.status),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: _priorityLabel(incident.priority),
                      color: _priorityColor(incident.priority),
                      icon: Icons.flag,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dirección
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  value: incident.address,
                ),
                const SizedBox(height: 12),

                // Fecha
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value:
                      '${incident.createdAt.day.toString().padLeft(2, '0')}/${incident.createdAt.month.toString().padLeft(2, '0')}/${incident.createdAt.year}',
                ),
                const SizedBox(height: 20),

                // Descripción
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    incident.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),

                // ─── Historial / Comentarios ─────────────────────
                const SizedBox(height: 24),
                Text(
                  'Historial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                if (incident.comments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No hay notas todavía.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...incident.comments.map((comment) => _CommentTile(comment: comment)),

                // ─── Formulario para admin ─────────────────────
                if (context.read<AuthProvider>().isAdmin) ...[
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Escribir una nota...',
                            prefixIcon: Icon(Icons.comment_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _sendingComment ? null : _sendComment,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            padding: EdgeInsets.zero,
                          ),
                          child: _sendingComment
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers de estado ---

  String _statusLabel(String status) {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en progreso':
        return 'En progreso';
      case 'resuelto':
        return 'Resuelto';
      case 'rechazada':
        return 'Rechazada';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pendiente':
        return AppColors.statusPending;
      case 'en progreso':
        return AppColors.statusInProgress;
      case 'resuelto':
        return AppColors.statusResolved;
      case 'rechazada':
        return AppColors.statusRejected;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pendiente':
        return Icons.schedule;
      case 'en progreso':
        return Icons.autorenew;
      case 'resuelto':
        return Icons.check_circle_outline;
      case 'rechazada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'critica':
        return 'Crítica';
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return priority;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critica':
        return AppColors.priorityCritical;
      case 'alta':
        return AppColors.priorityHigh;
      case 'media':
        return AppColors.priorityMedium;
      case 'baja':
        return AppColors.priorityLow;
      default:
        return Colors.grey;
    }
  }

  // --- Acciones admin ---

  Future<void> _handleAdminAction(String action) async {
    final provider = context.read<IncidentProvider>();

    switch (action) {
      case 'status':
        _showStatusDialog();
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar incidencia'),
            content: const Text(
              '¿Estás seguro? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.statusRejected,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await provider.deleteIncident(widget.incidentId);
          if (mounted) context.pop();
        }
        break;
      case 'priority':
        _showPriorityDialog();
        break;
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Cambiar estado'),
        children:
            [
              {
                'value': 'pendiente',
                'label': 'Pendiente',
                'icon': Icons.schedule,
              },
              {
                'value': 'en progreso',
                'label': 'En progreso',
                'icon': Icons.autorenew,
              },
              {
                'value': 'resuelto',
                'label': 'Resuelto',
                'icon': Icons.check_circle_outline,
              },
              {
                'value': 'rechazada',
                'label': 'Rechazada',
                'icon': Icons.cancel_outlined,
              },
            ].map((option) {
              return SimpleDialogOption(
                child: Row(
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      color: _statusColor(option['value'] as String),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(option['label'] as String),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = context.read<IncidentProvider>();
                  final success = await provider.updateIncident(
                    widget.incidentId,
                    {'estado': option['value']},
                  );
                  if (success) _loadIncident();
                },
              );
            }).toList(),
      ),
    );
  }

  void _openFullscreenGallery(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenGalleryPage(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Seleccionar prioridad'),
        children:
            [
              {'value': 'baja', 'label': 'Baja'},
              {'value': 'media', 'label': 'Media'},
              {'value': 'alta', 'label': 'Alta'},
              {'value': 'critica', 'label': 'Crítica'},
            ].map((option) {
              return SimpleDialogOption(
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: _priorityColor(option['value']!),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(option['label']!),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = context.read<IncidentProvider>();
                  final success = await provider.updateIncident(
                    widget.incidentId,
                    {'prioridad': option['value']},
                  );
                  if (success) _loadIncident();
                },
              );
            }).toList(),
      ),
    );
  }
}

// --- Widgets auxiliares ---

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullscreenGalleryPage({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGalleryPage> createState() =>
      _FullscreenGalleryPageState();
}

class _FullscreenGalleryPageState extends State<_FullscreenGalleryPage> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.imageUrls.length > 1
            ? Text(
                '${_currentPage + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(fontSize: 16),
              )
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white38,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = comment.creadoEn;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea del timeline
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              Container(width: 2, height: 50, color: colors.outlineVariant),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        comment.autorNombre ?? 'Sistema',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.texto,
                    style: TextStyle(color: colors.onSurface, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
