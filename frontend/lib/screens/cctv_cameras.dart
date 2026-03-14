import 'package:flutter/material.dart';

class CCTVCamerasScreen extends StatefulWidget {
  const CCTVCamerasScreen({super.key});

  @override
  State<CCTVCamerasScreen> createState() => _CCTVCamerasScreenState();
}

class _CCTVCamerasScreenState extends State<CCTVCamerasScreen> {
  final List<ParkingSpace> parkingSpaces = [
    ParkingSpace(id: 1, name: 'Zone A - Level 1', cameras: 3, occupancy: 28),
    ParkingSpace(id: 2, name: 'Zone A - Level 2', cameras: 3, occupancy: 32),
    ParkingSpace(id: 3, name: 'Zone B - East Wing', cameras: 4, occupancy: 45),
    ParkingSpace(id: 4, name: 'Zone B - West Wing', cameras: 4, occupancy: 38),
    ParkingSpace(id: 5, name: 'Zone C - Basement', cameras: 2, occupancy: 12),
  ];

  int? selectedSpaceId;
  int? selectedCamera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        title: const Text('CCTV Cameras'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Parking space selector
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Parking Space',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedSpaceId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            parkingSpaces
                                .firstWhere((s) => s.id == selectedSpaceId)
                                .name,
                            style: TextStyle(
                              color: Colors.cyanAccent.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: parkingSpaces.length,
                      itemBuilder: (context, index) {
                        final space = parkingSpaces[index];
                        final isSelected = selectedSpaceId == space.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              selectedSpaceId = space.id;
                              selectedCamera = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.cyanAccent.withValues(alpha: 0.15)
                                    : Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.cyanAccent
                                      : Colors.grey.shade800,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.videocam,
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          space.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.cyanAccent
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${space.occupancy}/${space.cameras * 16} occupied',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${space.cameras}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera selector and viewer
          if (selectedSpaceId != null)
            Expanded(
              flex: 3,
              child: _CameraViewerPanel(
                space: parkingSpaces.firstWhere((s) => s.id == selectedSpaceId),
                selectedCamera: selectedCamera,
                onCameraSelected: (camera) =>
                    setState(() => selectedCamera = camera),
              ),
            ),
        ],
      ),
    );
  }
}

class _CameraViewerPanel extends StatelessWidget {
  final ParkingSpace space;
  final int? selectedCamera;
  final Function(int) onCameraSelected;

  const _CameraViewerPanel({
    required this.space,
    required this.selectedCamera,
    required this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera selector tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    space.cameras,
                    (index) {
                      final cameraNum = index + 1;
                      final isSelected = selectedCamera == cameraNum;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => onCameraSelected(cameraNum),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.cyanAccent.shade700
                                  : Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.cyanAccent
                                    : Colors.grey.shade800,
                              ),
                            ),
                            child: Text(
                              'Cam $cameraNum',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Live video feed viewer
        Expanded(
          child: selectedCamera == null
              ? Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 64,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select a camera to view live footage',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _LiveFeedViewer(
                  spaceName: space.name,
                  cameraNumber: selectedCamera!,
                ),
        ),
      ],
    );
  }
}

class _LiveFeedViewer extends StatefulWidget {
  final String spaceName;
  final int cameraNumber;

  const _LiveFeedViewer({
    required this.spaceName,
    required this.cameraNumber,
  });

  @override
  State<_LiveFeedViewer> createState() => _LiveFeedViewerState();
}

class _LiveFeedViewerState extends State<_LiveFeedViewer> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video feed placeholder
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated live indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.videocam,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.spaceName} - Camera ${widget.cameraNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live stream active',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top info bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'REC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recording',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.signal_cellular_4_bar,
                  color: Colors.greenAccent,
                  size: 18,
                ),
                const SizedBox(width: 4),
                const Text(
                  '4G',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ControlButton(
                  icon: Icons.screenshot,
                  label: 'Screenshot',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Screenshot saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ControlButton(
                  icon: Icons.videocam_rounded,
                  label: 'Record',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recording started'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ControlButton(
                  icon: _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  label: _isFullscreen ? 'Exit' : 'Fullscreen',
                  onTap: () => setState(() => _isFullscreen = !_isFullscreen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingSpace {
  final int id;
  final String name;
  final int cameras;
  final int occupancy;

  ParkingSpace({
    required this.id,
    required this.name,
    required this.cameras,
    required this.occupancy,
  });
}
