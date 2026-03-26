import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/parking_slot.dart';
import '../services/api_service.dart';
import '../services/parking_service.dart';
import '../utils/responsive_utils.dart';
import 'payment.dart';

class ParkingListScreen extends StatefulWidget {
  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  List<dynamic> spaces = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }

  Future<void> _loadParkingSpaces() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final loadedSpaces = await ParkingService.getParkingSpaces();
      if (!mounted) return;

      setState(() {
        spaces = loadedSpaces;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showSlotsForSpace(Map<String, dynamic> space) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: _SpaceSlotsBottomSheet(space: space),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadParkingSpaces, child: const Text('Retry')),
                  ],
                ),
                )
              : spaces.isEmpty
                  ? const Center(child: Text('No parking spaces uploaded by vendors yet.'))
                  : Padding(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsivePadding(context, mobile: 10, tablet: 12, desktop: 16),
                      ),
                      child: ListView.separated(
                        itemCount: spaces.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final space = spaces[i] as Map<String, dynamic>;
                          final isActive = space['is_active'] == true;

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.local_parking,
                                color: isActive ? Colors.green : Colors.grey,
                                size: isMobile ? 28 : 34,
                              ),
                              title: Text(space['name']?.toString() ?? 'Unnamed Space'),
                              subtitle: Text(
                                '${space['location'] ?? space['address'] ?? 'No location'}\nSlots: ${space['total_slots'] ?? 0}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if ((space['google_map_link'] ?? '').toString().isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.map, color: Colors.blue),
                                      tooltip: 'Open in Google Maps',
                                      onPressed: () => launchUrl(
                                        Uri.parse(space['google_map_link'].toString()),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: isActive ? () => _showSlotsForSpace(space) : null,
                                    child: Text(isActive ? 'View Slots' : 'Inactive'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
  }
}

class _SpaceSlotsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> space;

  const _SpaceSlotsBottomSheet({required this.space});

  @override
  State<_SpaceSlotsBottomSheet> createState() => _SpaceSlotsBottomSheetState();
}

class _SpaceSlotsBottomSheetState extends State<_SpaceSlotsBottomSheet> {
  late final int _spaceId;
  List<ParkingSlot> _slots = [];
  bool _loading = true;
  String? _error;
  bool _socketConnected = false;
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _spaceId = widget.space['id'] as int;
    _loadSlots();
    _connectSocket();
  }

  String _buildWsUrl(int spaceId) {
    final base = ApiService.baseUrl.replaceFirst('/api', '');
    final secure = base.startsWith('https://');
    final host = base.replaceFirst('https://', '').replaceFirst('http://', '');
    final scheme = secure ? 'wss' : 'ws';
    return '$scheme://$host/ws/spaces/$spaceId/slots/';
  }

  Future<void> _loadSlots({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      final slotRows = await ParkingService.getSlots(_spaceId);
      final slots = slotRows
          .map((row) => ParkingSlot.fromJson(row as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _connectSocket() {
    final wsUrl = _buildWsUrl(_spaceId);
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel = channel;

    channel.stream.listen(
      (event) {
        if (!mounted) return;

        setState(() => _socketConnected = true);

        try {
          final data = jsonDecode(event.toString());
          if (data is Map<String, dynamic> && data['type'] == 'slot_update') {
            _loadSlots(silent: true);
          }
        } catch (_) {
          // ignore non-json heartbeat/connection messages
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _socketConnected = false);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _socketConnected = false);
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _reserveSlot(ParkingSlot slot) async {
    final result = await ParkingService.reserveSlot(spaceId: _spaceId, slotId: slot.id);
    if (!mounted) return;

    if (result['success'] == true) {
      final reservation = result['reservation'] as Map<String, dynamic>;
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            slotName: slot.label,
            slotId: slot.slotId,
            reservationId: reservation['id'] as int,
            amount: double.parse((reservation['booking_fee'] ?? reservation['amount'] ?? 0).toString()),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']?.toString() ?? 'Failed to reserve slot'),
          backgroundColor: Colors.red,
        ),
      );
      _loadSlots(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load slots: $_error'),
        ),
      );
    }

    return Column(
      children: [
        ListTile(
          title: Text(widget.space['name']?.toString() ?? 'Parking Space'),
          subtitle: Text(widget.space['location']?.toString() ?? widget.space['address']?.toString() ?? ''),
          onTap: (widget.space['google_map_link'] ?? '').toString().isNotEmpty
              ? () => launchUrl(
                    Uri.parse(widget.space['google_map_link'].toString()),
                    mode: LaunchMode.externalApplication,
                  )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 10, color: _socketConnected ? Colors.green : Colors.orange),
              const SizedBox(width: 6),
              Text(_socketConnected ? 'Realtime' : 'Connecting'),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _slots.isEmpty
              ? const Center(child: Text('No slots available in this space.'))
              : RefreshIndicator(
                  onRefresh: () => _loadSlots(),
                  child: ListView.builder(
                    itemCount: _slots.length,
                    itemBuilder: (context, i) {
                      final slot = _slots[i];
                      final isBlocked = slot.isOccupied || slot.isReserved;
                      final canReserve = slot.isActive && !isBlocked;

                      Color color;
                      if (!slot.isActive) {
                        color = Colors.grey;
                      } else if (slot.isOccupied) {
                        color = Colors.red;
                      } else if (slot.isReserved) {
                        color = Colors.orange;
                      } else {
                        color = Colors.green;
                      }

                      String label;
                      if (!slot.isActive) {
                        label = 'Inactive';
                      } else if (slot.isOccupied) {
                        label = 'Occupied';
                      } else if (slot.isReserved) {
                        label = 'Reserved';
                      } else {
                        label = 'Reserve';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.local_parking, color: color),
                          title: Text(slot.label),
                          subtitle: Text('ID: ${slot.slotId}'),
                          trailing: ElevatedButton(
                            onPressed: canReserve ? () => _reserveSlot(slot) : null,
                            child: Text(label),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}



