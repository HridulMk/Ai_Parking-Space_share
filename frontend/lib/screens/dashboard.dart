import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/parking_slot.dart';
import '../services/auth_service.dart';
import '../services/parking_service.dart';
import 'welcome.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final results = await Future.wait<dynamic>([
      AuthService.getUserProfile(),
      ParkingService.getParkingSpaces(),
      ParkingService.getReservations(),
      ParkingService.getParkingSlots(),
    ]);

    final profileResp = results[0] as Map<String, dynamic>;
    final spaces = (results[1] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    final reservations = (results[2] as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    final slots = results[3] as List<ParkingSlot>;

    Map<String, dynamic> user = {};
    if (profileResp['success'] == true && profileResp['user'] is Map<String, dynamic>) {
      user = profileResp['user'] as Map<String, dynamic>;
    } else {
      user = await AuthService.getUserData() ?? <String, dynamic>{};
    }

    final activeSpaces = spaces.where((s) => s['is_active'] == true).toList();

    final successfulBookings = reservations.where((r) {
      final status = (r['status'] ?? '').toString();
      return status == 'completed' || r['final_fee_paid'] == true || r['is_paid'] == true;
    }).length;

    final activeUsage = reservations.where((r) {
      final status = (r['status'] ?? '').toString();
      return status == 'reserved' || status == 'checked_in';
    }).length;

    final vacantSlots = slots.where((s) => !s.isOccupied && s.isActive).length;
    final occupiedSlots = slots.where((s) => s.isOccupied && s.isActive).length;
    final totalActiveSlots = vacantSlots + occupiedSlots;

    final nearbySpaces = activeSpaces.take(6).map((space) {
      final spaceId = space['id'];
      final spaceSlots = slots.where((slot) => slot.spaceId == spaceId).toList();
      final free = spaceSlots.where((slot) => !slot.isOccupied && slot.isActive).length;
      return _NearbySpace(
        name: (space['name'] ?? 'Parking Space').toString(),
        location: (space['location'] ?? space['address'] ?? 'Location unavailable').toString(),
        totalSlots: spaceSlots.length,
        vacantSlots: free,
        mapLink: (space['google_map_link'] ?? '').toString(),
      );
    }).toList();

    final liveLocation = nearbySpaces.isNotEmpty ? nearbySpaces.first.location : 'Location unavailable';

    return _DashboardData(
      user: user,
      totalReservations: reservations.length,
      successfulReservations: successfulBookings,
      activeReservations: activeUsage,
      nearbyParkingCount: activeSpaces.length,
      totalSlots: totalActiveSlots,
      vacantSlots: vacantSlots,
      occupiedSlots: occupiedSlots,
      liveLocation: liveLocation,
      nearbySpaces: nearbySpaces,
    );
  }

  void _reload() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  String _fullName(Map<String, dynamic> user) {
    final first = (user['first_name'] ?? '').toString().trim();
    final last = (user['last_name'] ?? '').toString().trim();
    final joined = '$first $last'.trim();
    if (joined.isNotEmpty) return joined;
    return (user['username'] ?? 'User').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F7FF), Color(0xFFE9FFF5)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load dashboard: ${snapshot.error}'),
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No dashboard data available.'));
              }

              final user = data.user;
              final userName = _fullName(user);
              final email = (user['email'] ?? 'Not available').toString();
              final phone = (user['phone'] ?? 'Not available').toString();
              final userType = (user['user_type'] ?? 'customer').toString();

              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'App Dashboard',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
                        IconButton(
                          onPressed: () async {
                            await AuthService.logout();
                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(email, style: const TextStyle(color: Color(0xFF4B5563))),
                          const SizedBox(height: 4),
                          Text('Phone: $phone', style: const TextStyle(color: Color(0xFF4B5563))),
                          const SizedBox(height: 10),
                          Chip(label: Text('Role: ${userType.toUpperCase()}')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF0F172A),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Live Location', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 2),
                                Text(
                                  data.liveLocation,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _KpiCard(title: 'Total Bookings', value: '${data.totalReservations}', icon: Icons.receipt_long, color: const Color(0xFF0EA5E9)),
                        _KpiCard(title: 'Successful Uses', value: '${data.successfulReservations}', icon: Icons.verified, color: const Color(0xFF22C55E)),
                        _KpiCard(title: 'Active Sessions', value: '${data.activeReservations}', icon: Icons.directions_car, color: const Color(0xFFF59E0B)),
                        _KpiCard(title: 'Nearby Spaces', value: '${data.nearbyParkingCount}', icon: Icons.local_parking, color: const Color(0xFF6366F1)),
                        _KpiCard(title: 'Vacant Slots', value: '${data.vacantSlots}', icon: Icons.event_available, color: const Color(0xFF10B981)),
                        _KpiCard(title: 'Occupied Slots', value: '${data.occupiedSlots}', icon: Icons.event_busy, color: const Color(0xFFEF4444)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vacancy Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: data.totalSlots == 0 ? 0 : (data.vacantSlots / math.max(1, data.totalSlots)),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: const Color(0xFF16A34A),
                          ),
                          const SizedBox(height: 8),
                          Text('Vacant ${data.vacantSlots} of ${data.totalSlots} active slots'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nearby Parking Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (data.nearbySpaces.isEmpty)
                      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('No nearby parking spaces available right now.'))),
                    ...data.nearbySpaces.map(
                      (space) => Card(
                        elevation: 0.6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(space.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(space.location, style: const TextStyle(color: Color(0xFF4B5563))),
                              const SizedBox(height: 8),
                              Text('Nearby slot count: ${space.totalSlots}'),
                              Text('Vacant slots: ${space.vacantSlots}'),
                              if (space.mapLink.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Map: ${space.mapLink}', style: const TextStyle(fontSize: 12, color: Color(0xFF0EA5E9))),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _DashboardData {
  final Map<String, dynamic> user;
  final int totalReservations;
  final int successfulReservations;
  final int activeReservations;
  final int nearbyParkingCount;
  final int totalSlots;
  final int vacantSlots;
  final int occupiedSlots;
  final String liveLocation;
  final List<_NearbySpace> nearbySpaces;

  _DashboardData({
    required this.user,
    required this.totalReservations,
    required this.successfulReservations,
    required this.activeReservations,
    required this.nearbyParkingCount,
    required this.totalSlots,
    required this.vacantSlots,
    required this.occupiedSlots,
    required this.liveLocation,
    required this.nearbySpaces,
  });
}

class _NearbySpace {
  final String name;
  final String location;
  final int totalSlots;
  final int vacantSlots;
  final String mapLink;

  _NearbySpace({
    required this.name,
    required this.location,
    required this.totalSlots,
    required this.vacantSlots,
    required this.mapLink,
  });
}





