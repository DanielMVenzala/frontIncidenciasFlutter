import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/incident_model.dart';
import '../../providers/incident_provider.dart';

class IncidentsMapPage extends StatefulWidget {
  const IncidentsMapPage({super.key});

  @override
  State<IncidentsMapPage> createState() => _IncidentsMapPageState();
}

class _IncidentsMapPageState extends State<IncidentsMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  // Centro de Martos
  static const _martosCenter = LatLng(37.7210, -3.9720);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadAllIncidents();
    });
  }

  Set<Marker> _buildMarkers(List<IncidentModel> incidents) {
    return incidents
        .where((i) => i.hasCoordinates && !i.isRejected)
        .map((incident) => Marker(
              markerId: MarkerId(incident.id),
              position: LatLng(incident.latitud!, incident.longitud!),
              icon: _markerIcon(incident.status),
              infoWindow: InfoWindow(
                title: incident.title,
                snippet: _statusLabel(incident.status),
                onTap: () => context.push(
                  AppRoutes.incidentDetail.replaceFirst(':id', incident.id),
                ),
              ),
            ))
        .toSet();
  }

  BitmapDescriptor _markerIcon(String status) {
    switch (status) {
      case 'pendiente':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'en progreso':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'resuelto':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'rechazada':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de incidencias')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _martosCenter,
              zoom: 15,
            ),
            markers: _buildMarkers(provider.incidents),
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),

          // Leyenda
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem(AppColors.statusPending, 'Pendiente'),
                  const SizedBox(height: 4),
                  _legendItem(AppColors.statusInProgress, 'En progreso'),
                  const SizedBox(height: 4),
                  _legendItem(AppColors.statusResolved, 'Resuelto'),
                ],
              ),
            ),
          ),

          if (provider.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
