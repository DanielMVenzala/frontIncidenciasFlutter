import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/incident_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';

class IncidentsListPage extends StatefulWidget {
  final String title;

  const IncidentsListPage({super.key, required this.title});

  @override
  State<IncidentsListPage> createState() => _IncidentsListPageState();
}

class _IncidentsListPageState extends State<IncidentsListPage> {
  final _searchController = TextEditingController();
  String? _filterEstado;
  String? _filterPrioridad;
  String _orderBy = 'creadoEn';
  String _order = 'DESC';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reload();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{
      'orderBy': _orderBy,
      'order': _order,
    };
    if (_searchController.text.trim().length >= 3) {
      filters['search'] = _searchController.text.trim();
    }
    if (_filterEstado != null) filters['estado'] = _filterEstado;
    if (_filterPrioridad != null) filters['prioridad'] = _filterPrioridad;
    return filters;
  }

  Future<void> _reload() {
    final auth = context.read<AuthProvider>();
    final incidents = context.read<IncidentProvider>();

    if (auth.isAdmin) {
      return incidents.loadAllIncidents(filters: _buildFilters());
    } else {
      return incidents.loadMyIncidents(auth.user!.id);
    }
  }

  void _applyFilters() {
    _reload();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterEstado = null;
      _filterPrioridad = null;
      _orderBy = 'creadoEn';
      _order = 'DESC';
    });
    _reload();
  }

  bool get _isAdmin => context.read<AuthProvider>().isAdmin;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              tooltip: _showFilters ? 'Ocultar filtros' : 'Filtros',
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters && _isAdmin) _buildFilterSection(),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por título, descripción...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
          const SizedBox(height: 12),

          // Filtros en fila
          Row(
            children: [
              // Estado
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterEstado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'en progreso', child: Text('En progreso')),
                    DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                    DropdownMenuItem(value: 'rechazada', child: Text('Rechazada')),
                  ],
                  onChanged: (v) {
                    setState(() => _filterEstado = v);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Prioridad
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterPrioridad,
                  decoration: const InputDecoration(
                    labelText: 'Prioridad',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todas')),
                    DropdownMenuItem(value: 'critica', child: Text('Crítica')),
                    DropdownMenuItem(value: 'alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'media', child: Text('Media')),
                    DropdownMenuItem(value: 'baja', child: Text('Baja')),
                  ],
                  onChanged: (v) {
                    setState(() => _filterPrioridad = v);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ordenación
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _orderBy,
                  decoration: const InputDecoration(
                    labelText: 'Ordenar por',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'creadoEn', child: Text('Fecha creación')),
                    DropdownMenuItem(value: 'actualizadoEn', child: Text('Última actualización')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _orderBy = v);
                      _applyFilters();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Dirección
              IconButton(
                icon: Icon(
                  _order == 'ASC' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: AppColors.primary,
                ),
                tooltip: _order == 'ASC' ? 'Ascendente' : 'Descendente',
                onPressed: () {
                  setState(() => _order = _order == 'ASC' ? 'DESC' : 'ASC');
                  _applyFilters();
                },
              ),
              // Limpiar filtros
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(IncidentProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _reload(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            const Text(
              'No hay incidencias',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _reload(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.incidents.length,
        itemBuilder: (context, index) {
          final incident = provider.incidents[index];
          return _IncidentCard(incident: incident);
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IncidentModel incident;

  const _IncidentCard({required this.incident});

  Color _priorityColor() {
    switch (incident.priority) {
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

  String _statusLabel() {
    switch (incident.status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en progreso':
        return 'En progreso';
      case 'resuelto':
        return 'Resuelto';
      case 'rechazada':
        return 'Rechazada';
      default:
        return incident.status;
    }
  }

  Color _statusColor() {
    switch (incident.status) {
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

  IconData _statusIcon() {
    switch (incident.status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(AppRoutes.incidentDetail.replaceFirst(':id', incident.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Miniatura con Hero
              if (incident.imageUrls.isNotEmpty) ...[
                Hero(
                  tag: 'incident_image_${incident.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      incident.imageUrls.first,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else ...[
                // Indicador de prioridad (sin imagen)
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _priorityColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Chip de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(),
                              size: 13, color: _statusColor()),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
