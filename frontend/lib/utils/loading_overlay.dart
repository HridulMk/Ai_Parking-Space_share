import 'package:flutter/material.dart';

/// Helper class to manage loading dialog/overlay throughout the app
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Show a loading overlay with animated logo
  static void show(BuildContext context) {
    if (_overlayEntry != null) return; // Already showing

    _overlayEntry = OverlayEntry(
      builder: (context) => const _LoadingOverlayWidget(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Show loading for a specific duration
  static Future<void> showFor(
    BuildContext context, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    show(context);
    await Future.delayed(duration);
    hide();
  }
}

/// Internal widget for the loading overlay
class _LoadingOverlayWidget extends StatefulWidget {
  const _LoadingOverlayWidget();

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.cyan.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Inner rotating ring
                RotationTransition(
                  turns: Tween<double>(begin: 1, end: 0)
                      .animate(_rotationController),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Pulsing glow
                ScaleTransition(
                  scale: _pulseController,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // Main logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.cyan,
                        Colors.teal.shade700,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    size: 55,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
