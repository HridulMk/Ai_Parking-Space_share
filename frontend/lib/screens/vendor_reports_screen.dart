// ignore_for_file: deprecated_member_use, unnecessary_cast
import 'package:flutter/material.dart';
import '../models/parking_slot.dart';
import '../services/parking_service.dart';

class VendorReportsScreen extends StatefulWidget {
  const VendorReportsScreen({super.key});

  @override
  State<VendorReportsScreen> createState() => _VendorReportsScreenState();
}

class _VendorReportsScreenState extends State<VendorReportsScreen> {
  bool _loading = true;
  String? _error;

  int _totalSpaces = 0;
  int _activeSpaces = 0;
  int _totalSlots = 0;
  int _occupiedSlots = 0;
  int _totalReservations = 0;
  int _completedReservations = 0;
  double _totalRevenue = 0;
  List<_SpaceReport> _spaceReports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ParkingService.getParkingSpaces(),
        ParkingService.getParkingSlots(),
        ParkingService.getReservations(),
      ]);

      final spaces = (results[0] as List).whereType<Map<String, dynamic>>().toList();
      final slots = results[1] as List<ParkingSlot>;
      final reservations = (results[2] as List).whereType<Map<String, dynamic>>().toList();

      final completed = reservations.where((r) => r['status'] == 'completed').toList();
      final revenue = completed.fold<double>(
        0,
        (sum, r) => sum + (double.tryParse((r['final_fee'] ?? r['amount'] ?? '0').toString()) ?? 0.0).clamp(0, double.infinity),
      );

      final reports = spaces.map((s) {
        final spaceId = s['id'];
        final spaceSlots = slots.where((sl) => sl.spaceId == spaceId).toList();
        final occupied = spaceSlots.where((sl) => sl.isOccupied).length;
        return _SpaceReport(
          name: s['name']?.toString() ?? 'Space',
          totalSlots: spaceSlots.length,
          occupiedSlots: occupied,
          reservations: 0,
          isActive: s['is_active'] == true,
        );
      }).toList();

      setState(() {
        _totalSpaces = spaces.length;
        _activeSpaces = spaces.where((s) => s['is_active'] == true).length;
        _totalSlots = slots.length;
        _occupiedSlots = slots.where((sl) => sl.isOccupied).length;
        _totalReservations = reservations.length;
        _completedReservations = completed.length;
        _totalRevenue = revenue;
        _spaceReports = reports;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF161B22),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _sectionTitle('Overview'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _kpi('Total Spaces', '$_totalSpaces', Icons.local_parking, Colors.cyanAccent),
                          _kpi('Active Spaces', '$_activeSpaces', Icons.check_circle, Colors.greenAccent),
                          _kpi('Total Slots', '$_totalSlots', Icons.grid_view, Colors.blueAccent),
                          _kpi('Occupied', '$_occupiedSlots', Icons.event_busy, Colors.redAccent),
                          _kpi('Reservations', '$_totalReservations', Icons.receipt_long, Colors.orangeAccent),
                          _kpi('Completed', '$_completedReservations', Icons.verified, Colors.tealAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.euro, color: Colors.cyanAccent, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Revenue', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                Text('€${_totalRevenue.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Occupancy by Space'),
                      const SizedBox(height: 10),
                      if (_spaceReports.isEmpty)
                        const Text('No spaces found.', style: TextStyle(color: Colors.white54))
                      else
                        ..._spaceReports.map((r) => _spaceCard(r)),
                    ],
                  ),
                ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));

  Widget _kpi(String label, String value, IconData icon, Color color) {
    final w = (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;
    return Container(
      width: w,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ]),
    );
  }

  Widget _spaceCard(_SpaceReport r) {
    final pct = r.totalSlots == 0 ? 0.0 : r.occupiedSlots / r.totalSlots;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.local_parking, color: r.isActive ? Colors.cyanAccent : Colors.white30),
          const SizedBox(width: 8),
          Expanded(child: Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: r.isActive ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(r.isActive ? 'Active' : 'Inactive',
                style: TextStyle(color: r.isActive ? Colors.greenAccent : Colors.white38, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${r.occupiedSlots}/${r.totalSlots} occupied',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  color: pct > 0.8 ? Colors.redAccent : pct > 0.5 ? Colors.orangeAccent : Colors.greenAccent,
                ),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('occupancy', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ]),
      ]),
    );
  }
}

class _SpaceReport {
  final String name;
  final int totalSlots;
  final int occupiedSlots;
  final int reservations;
  final bool isActive;

  _SpaceReport({
    required this.name,
    required this.totalSlots,
    required this.occupiedSlots,
    required this.reservations,
    required this.isActive,
  });
}
