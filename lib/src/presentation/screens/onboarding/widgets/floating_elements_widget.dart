import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingElementsWidget extends StatefulWidget {
  final int elementCount;
  final Color color;

  const FloatingElementsWidget({
    super.key,
    this.elementCount = 20,
    required this.color,
  });

  @override
  State<FloatingElementsWidget> createState() => _FloatingElementsWidgetState();
}

class _FloatingElementsWidgetState extends State<FloatingElementsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Offset> _positions;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.elementCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 100)),
        vsync: this,
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Generate random positions
    final random = math.Random();
    _positions = List.generate(widget.elementCount, (index) {
      return Offset(random.nextDouble(), random.nextDouble());
    });

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: List.generate(widget.elementCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final animationValue = _animations[index].value;
            final baseX = _positions[index].dx * size.width;
            final baseY = _positions[index].dy * size.height;

            final floatX =
                baseX + (math.sin(animationValue * 2 * math.pi) * 20);
            final floatY =
                baseY + (math.cos(animationValue * 2 * math.pi) * 30);

            return Positioned(
              left: floatX,
              top: floatY,
              child: Opacity(
                opacity: 0.1 + (animationValue * 0.3),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
