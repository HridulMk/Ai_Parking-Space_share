import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import 'welcome.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isBackendConnected = true;
  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _connectionTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connected = await AuthService.checkBackendConnection();
    if (mounted) {
      setState(() => _isBackendConnected = connected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purpleAccent.withValues(alpha: 0.15),
                          Colors.purpleAccent.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello, Admin!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage the entire parking system',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // System overview
                  const Text(
                    'System Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.store,
                          label: 'Vendors',
                          value: '12',
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.people,
                          label: 'Users',
                          value: '1.2K',
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.local_parking,
                          label: 'Total Spaces',
                          value: '5K+',
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.trending_up,
                          label: 'Daily Revenue',
                          value: '€8.5K',
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Management sections
                  const Text(
                    'Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.videocam_outlined,
                    title: 'CCTV Cameras',
                    subtitle: 'View live parking lot cameras',
                    onTap: () => Navigator.of(context).pushNamed('/cctv-cameras'),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.store_outlined,
                    title: 'Manage Vendors',
                    subtitle: 'Add, edit, or remove parking vendors',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.people_outline,
                    title: 'Manage Users',
                    subtitle: 'View and manage customer accounts',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.security_outlined,
                    title: 'Manage Security',
                    subtitle: 'Control security personnel access',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.receipt_long,
                    title: 'View Reports',
                    subtitle: 'Detailed system and revenue reports',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.settings_outlined,
                    title: 'System Settings',
                    subtitle: 'Configure system-wide parameters',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.warning_outlined,
                    title: 'System Alerts',
                    subtitle: 'View critical system notifications',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // Alerts
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outlined, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('System Alert', style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              )),
                              const SizedBox(height: 4),
                              Text('2 vendors pending verification', style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (!_isBackendConnected)
            Container(
              color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Warning: Backend server is not reachable. Some features may not work.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          Text(label, style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
                  Text(subtitle, style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
