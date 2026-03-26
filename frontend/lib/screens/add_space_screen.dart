// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../services/parking_service.dart';

class AddSpaceScreen extends StatefulWidget {
  const AddSpaceScreen({super.key});

  @override
  State<AddSpaceScreen> createState() => _AddSpaceScreenState();
}

class _AddSpaceScreenState extends State<AddSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _slotsCtrl = TextEditingController();
  final _openCtrl = TextEditingController(text: '08:00:00');
  final _closeCtrl = TextEditingController(text: '22:00:00');
  final _mapLinkCtrl = TextEditingController();

  ll.LatLng? _pickedLatLng;
  PlatformFile? _imageFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slotsCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _mapLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() => _imageFile = result.files.single);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<ll.LatLng>(
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(initial: _pickedLatLng),
      ),
    );
    if (result != null) {
      setState(() {
        _pickedLatLng = result;
        _mapLinkCtrl.text =
            'https://www.google.com/maps?q=${result.latitude},${result.longitude}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLatLng == null && _mapLinkCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on the map or provide a Google Maps link.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final location = _pickedLatLng != null
        ? '${_pickedLatLng!.latitude.toStringAsFixed(6)}, ${_pickedLatLng!.longitude.toStringAsFixed(6)}'
        : _mapLinkCtrl.text.trim();

    final result = await ParkingService.createParkingSpace(
      name: _nameCtrl.text.trim(),
      numberOfSlots: int.parse(_slotsCtrl.text.trim()),
      location: location,
      openTime: _openCtrl.text.trim(),
      closeTime: _closeCtrl.text.trim(),
      googleMapLink: _mapLinkCtrl.text.trim(),
      imageBytes: _imageFile?.bytes,
      imagePath: _imageFile?.path,
      imageFileName: _imageFile?.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking space created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']?.toString() ?? 'Failed to create space'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Add New Parking Space', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section('Space Details', [
              _field(_nameCtrl, 'Space Name', Icons.local_parking,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _field(_slotsCtrl, 'Number of Slots', Icons.grid_view,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? 'Enter a valid number' : null;
                  }),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_openCtrl, 'Open Time', Icons.access_time)),
                const SizedBox(width: 12),
                Expanded(child: _field(_closeCtrl, 'Close Time', Icons.access_time)),
              ]),
            ]),
            const SizedBox(height: 16),
            _section('Location', [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map),
                  label: Text(_pickedLatLng == null
                      ? 'Pick Location on Map'
                      : 'Location Picked ✓  (tap to change)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pickedLatLng == null ? const Color(0xFF0EA5E9) : Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              if (_pickedLatLng != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Lat: ${_pickedLatLng!.latitude.toStringAsFixed(6)},  Lng: ${_pickedLatLng!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              _field(_mapLinkCtrl, 'Or paste Google Maps link', Icons.link),
            ]),
            const SizedBox(height: 16),
            _section('Parking Image (optional)', [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2128),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: Colors.white38, size: 36),
                            SizedBox(height: 8),
                            Text('Tap to select image', style: TextStyle(color: Colors.white38)),
                          ],
                        )
                      : _buildImagePreview(),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Parking Space'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _imageFile!.bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_imageFile!.bytes!, fit: BoxFit.cover, width: double.infinity),
      );
    } else if (!kIsWeb && _imageFile!.path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(_imageFile!.path!), fit: BoxFit.cover, width: double.infinity),
      );
    }
    return Center(child: Text(_imageFile!.name, style: const TextStyle(color: Colors.white70)));
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
        filled: true,
        fillColor: const Color(0xFF0D1117),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// ── Location Picker ──────────────────────────────────────────────────────────

class _LocationPickerScreen extends StatefulWidget {
  final ll.LatLng? initial;
  const _LocationPickerScreen({this.initial});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  ll.LatLng? _picked;
  late final MapController _mapCtrl;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? const ll.LatLng(3.1390, 101.6869);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _picked),
              child: const Text('Confirm', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (_, latlng) => setState(() => _picked = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parking_app',
              ),
              if (_picked != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _picked!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ]),
            ],
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Text('Tap on the map to pin the parking location',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                if (_picked != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Lat: ${_picked!.latitude.toStringAsFixed(6)},  Lng: ${_picked!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _picked == null ? null : () => Navigator.pop(context, _picked),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm Location', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
