import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/incident_model.dart';
import '../../providers/incident_provider.dart';
import '../../services/incident_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadAllIncidents();
    });
  }

  /// Abre el diálogo de filtros y, si el usuario confirma, descarga el Excel.
  Future<void> _showDownloadDialog() async {
    DateTime? desde;
    DateTime? hasta;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            String formatDate(DateTime? d) =>
                d == null ? 'Seleccionar' : '${d.day}/${d.month}/${d.year}';

            return AlertDialog(
              title: const Text('Descargar informe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtra por rango de fechas (opcional):',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.calendar_today, size: 20),
                    title: const Text('Desde', style: TextStyle(fontSize: 13)),
                    subtitle: Text(formatDate(desde),
                        style: const TextStyle(fontSize: 12)),
                    trailing: desde != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setLocalState(() => desde = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: desde ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setLocalState(() => desde = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.calendar_today, size: 20),
                    title: const Text('Hasta', style: TextStyle(fontSize: 13)),
                    subtitle: Text(formatDate(hasta),
                        style: const TextStyle(fontSize: 12)),
                    trailing: hasta != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setLocalState(() => hasta = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: hasta ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setLocalState(() => hasta = picked);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Descargar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _downloading = true);
    try {
      final filters = <String, dynamic>{};
      if (desde != null) {
        filters['desde'] =
            '${desde!.year}-${desde!.month.toString().padLeft(2, '0')}-${desde!.day.toString().padLeft(2, '0')}';
      }
      if (hasta != null) {
        filters['hasta'] =
            '${hasta!.year}-${hasta!.month.toString().padLeft(2, '0')}-${hasta!.day.toString().padLeft(2, '0')}';
      }

      final service = context.read<IncidentService>();
      final filePath = await service.downloadIncidentsReport(
        filters: filters.isEmpty ? null : filters,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe descargado correctamente')),
        );
      }
      // Abrir el archivo con la app por defecto del dispositivo
      await OpenFilex.open(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.incidents;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: _downloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_download_outlined),
            tooltip: 'Descargar informe',
            onPressed: _downloading ? null : _showDownloadDialog,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : incidents.isEmpty
              ? const Center(child: Text('No hay incidencias registradas'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen
                      _SummaryCards(incidents: incidents),
                      const SizedBox(height: 24),

                      // Por estado (donut)
                      _SectionTitle(title: 'Por estado', textColor: textColor),
                      const SizedBox(height: 12),
                      _StatusPieChart(incidents: incidents),
                      const SizedBox(height: 24),

                      // Por prioridad (barras horizontales)
                      _SectionTitle(title: 'Por prioridad', textColor: textColor),
                      const SizedBox(height: 12),
                      _PriorityBarChart(incidents: incidents, textColor: textColor),
                      const SizedBox(height: 24),

                      // Por mes (barras verticales)
                      _SectionTitle(title: 'Por mes', textColor: textColor),
                      const SizedBox(height: 12),
                      _MonthlyBarChart(incidents: incidents, textColor: textColor),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}

// ─── Tarjetas resumen ────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  final List<IncidentModel> incidents;

  const _SummaryCards({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final total = incidents.length;
    final pending = incidents.where((i) => i.status == 'pendiente').length;
    final inProgress = incidents.where((i) => i.isInProgress).length;
    final resolved = incidents.where((i) => i.isClosed).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _StatCard(label: 'Total', value: total, color: AppColors.primary),
        _StatCard(label: 'Pendientes', value: pending, color: AppColors.statusPending),
        _StatCard(label: 'En progreso', value: inProgress, color: AppColors.statusInProgress),
        _StatCard(label: 'Resueltas', value: resolved, color: AppColors.statusResolved),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Donut por estado ────────────────────────────────────

class _StatusPieChart extends StatelessWidget {
  final List<IncidentModel> incidents;

  const _StatusPieChart({required this.incidents});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {};
    for (final i in incidents) {
      counts[i.status] = (counts[i.status] ?? 0) + 1;
    }

    final entries = [
      _PieEntry('Pendiente', counts['pendiente'] ?? 0, AppColors.statusPending),
      _PieEntry('En progreso', counts['en progreso'] ?? 0, AppColors.statusInProgress),
      _PieEntry('Resuelto', counts['resuelto'] ?? 0, AppColors.statusResolved),
      _PieEntry('Rechazada', counts['rechazada'] ?? 0, AppColors.statusRejected),
    ].where((e) => e.value > 0).toList();

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: entries
                    .map((e) => PieChartSectionData(
                          value: e.value.toDouble(),
                          color: e.color,
                          title: '${e.value}',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: e.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PieEntry {
  final String label;
  final int value;
  final Color color;
  _PieEntry(this.label, this.value, this.color);
}

// ─── Barras horizontales por prioridad ───────────────────

class _PriorityBarChart extends StatelessWidget {
  final List<IncidentModel> incidents;
  final Color textColor;

  const _PriorityBarChart({required this.incidents, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final priorities = ['baja', 'media', 'alta', 'critica'];
    final labels = ['Baja', 'Media', 'Alta', 'Crítica'];
    final colors = [
      AppColors.priorityLow,
      AppColors.priorityMedium,
      AppColors.priorityHigh,
      AppColors.priorityCritical,
    ];

    final counts = priorities.map((p) => incidents.where((i) => i.priority == p).length.toDouble()).toList();
    final maxVal = counts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal > 0 ? maxVal + 1 : 5,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${labels[group.x]}: ${rod.toY.toInt()}',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[value.toInt()],
                    style: TextStyle(fontSize: 11, color: textColor),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(fontSize: 11, color: textColor),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(
            4,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i],
                  color: colors[i],
                  width: 28,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Barras por mes ──────────────────────────────────────

class _MonthlyBarChart extends StatelessWidget {
  final List<IncidentModel> incidents;
  final Color textColor;

  const _MonthlyBarChart({required this.incidents, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - (5 - i));
      return date;
    });

    final monthLabels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    final counts = months.map((m) {
      return incidents
          .where((i) => i.createdAt.year == m.year && i.createdAt.month == m.month)
          .length
          .toDouble();
    }).toList();

    final maxVal = counts.isNotEmpty ? counts.reduce((a, b) => a > b ? a : b) : 0.0;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal > 0 ? maxVal + 1 : 5,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final m = months[group.x];
                return BarTooltipItem(
                  '${monthLabels[m.month - 1]} ${m.year}: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                  final m = months[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      monthLabels[m.month - 1],
                      style: TextStyle(fontSize: 11, color: textColor),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == value.roundToDouble()) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(fontSize: 11, color: textColor),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(
            months.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i],
                  color: AppColors.primary,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
