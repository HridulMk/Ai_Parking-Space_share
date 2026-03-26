// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  ll.LatLng? _currentLocation;
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() { _loading = true; _error = null; });

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _loading = false; });
        if (!mounted) return;
        await _showDialog(
          icon: Icons.location_disabled,
          iconColor: Colors.orangeAccent,
          title: 'Location Services Off',
          message: 'GPS is turned off on your device. Please enable location services in your device settings to use this feature.',
          primaryLabel: 'Open Settings',
          onPrimary: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
          secondaryLabel: 'Cancel',
          onSecondary: () => Navigator.pop(context),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Show rationale dialog before requesting if not yet decided
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        final proceed = await _showPermissionRationale();
        if (!proceed) {
          setState(() { _loading = false; });
          return;
        }
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() { _loading = false; });
        if (!mounted) return;
        await _showDialog(
          icon: Icons.location_off,
          iconColor: Colors.redAccent,
          title: 'Permission Denied',
          message: 'Location permission was denied. Please allow location access to see your position on the map.',
          primaryLabel: 'Try Again',
          onPrimary: () { Navigator.pop(context); _fetchLocation(); },
          secondaryLabel: 'Cancel',
          onSecondary: () => Navigator.pop(context),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() { _loading = false; });
        if (!mounted) return;
        await _showDialog(
          icon: Icons.lock,
          iconColor: Colors.redAccent,
          title: 'Permission Blocked',
          message: 'Location access is permanently blocked. Open app settings and enable location permission manually.',
          primaryLabel: 'Open Settings',
          onPrimary: () async {
            Navigator.pop(context);
            await Geolocator.openAppSettings();
          },
          secondaryLabel: 'Cancel',
          onSecondary: () => Navigator.pop(context),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latlng = ll.LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = latlng;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(latlng, 15);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: $e';
        _loading = false;
      });
    }
  }

  /// Shows the rationale dialog before the OS permission prompt.
  /// Returns true if the user wants to proceed.
  Future<bool> _showPermissionRationale() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: Colors.cyanAccent, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Allow Location Access',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'ParkAI needs access to your device location to show your position on the map and help you find nearby parking spaces.',
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    _PermissionRow(icon: Icons.map, text: 'Show your position on the map'),
                    SizedBox(height: 8),
                    _PermissionRow(icon: Icons.local_parking, text: 'Find nearby parking spaces'),
                    SizedBox(height: 8),
                    _PermissionRow(icon: Icons.directions, text: 'Get directions from your location'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Allow Location', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Not Now', style: TextStyle(color: Colors.white54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _showDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    required String secondaryLabel,
    required VoidCallback onSecondary,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel, style: const TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: onPrimary,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }

  void _openInGoogleMaps() {
    if (_currentLocation == null) return;
    final lat = _currentLocation!.latitude;
    final lng = _currentLocation!.longitude;
    launchUrl(
      Uri.parse('https://www.google.com/maps?q=$lat,$lng'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Live Location', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh location',
            onPressed: _fetchLocation,
          ),
          if (_currentLocation != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open in Google Maps',
              onPressed: _openInGoogleMaps,
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 16),
                  Text('Getting your location...', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, color: Colors.redAccent, size: 56),
                        const SizedBox(height: 16),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 15)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation!,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.parking_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 60,
                              height: 60,
                              child: Column(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.cyanAccent.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Coordinates card at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.cyanAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Your Location',
                                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)},  '
                                    'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.directions, color: Colors.cyanAccent),
                              tooltip: 'Open in Google Maps',
                              onPressed: _openInGoogleMaps,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Recenter FAB
                    Positioned(
                      bottom: 90,
                      right: 16,
                      child: FloatingActionButton.small(
                        backgroundColor: const Color(0xFF161B22),
                        onPressed: () => _mapController.move(_currentLocation!, 15),
                        child: const Icon(Icons.my_location, color: Colors.cyanAccent),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PermissionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }
}
