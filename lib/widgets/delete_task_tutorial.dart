import 'package:flutter/material.dart';

class DeleteTaskTutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const DeleteTaskTutorialOverlay({super.key, required this.onDismiss});

  @override
  State<DeleteTaskTutorialOverlay> createState() =>
      _DeleteTaskTutorialOverlayState();
}

class _DeleteTaskTutorialOverlayState extends State<DeleteTaskTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _positionAnimation = Tween<double>(begin: 0.0, end: -100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      onPanDown: (_) => widget.onDismiss(), // Dismiss on any touch
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.black54, // Dim background
        child: Stack(
          children: [
            Positioned(
              top: 180, // Approximate position of the first task
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_positionAnimation.value, 0),
                          child: Opacity(
                            opacity:
                                _opacityAnimation.value *
                                (1.0 - _controller.value), // Fade out at end
                            child: const Icon(
                              Icons.touch_app,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Swipe left to delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap anywhere to dismiss',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
